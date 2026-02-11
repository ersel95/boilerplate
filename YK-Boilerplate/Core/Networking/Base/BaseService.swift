import Alamofire
import Foundation
import Combine

// MARK: - Base Service
// Generic service class for all API calls.
// Supports async/await and Combine publishers.

public class BaseService<U: APITargetType> {

    // MARK: - SSL Pinning
    // TODO: Add your SSL certificates to Assets/Certs/ and configure pinning here.
    private var serverTrustManager: ServerTrustManager {
        // In dev/staging, disable SSL pinning for easier testing
        if EnvironmentsConstants.currentEnvironment == .dev {
            return ServerTrustManager(
                allHostsMustBeEvaluated: false,
                evaluators: [EnvironmentsConstants.apiBaseUrl: DisabledTrustEvaluator()]
            )
        }

        // TODO: For production, configure certificate pinning:
        // let certs = Bundle.main.af.certificates
        // return ServerTrustManager(evaluators: ["your.api.com": PinnedCertificatesTrustEvaluator(certificates: certs)])
        return ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [:])
    }

    // MARK: - Request Deduplication
    private var activeRequests: [String: Request] = [:]
    private let lock = NSLock()

    init() {}

    private func tryStartRequest(key: String, method: HTTPMethod, createRequest: () -> Request) -> Request? {
        lock.lock()
        defer { lock.unlock() }

        if activeRequests[key] != nil {
            return nil
        }

        let req = createRequest()
        activeRequests[key] = req
        return req
    }

    private func removeRequest(key: String, request: Request) {
        lock.lock()
        defer { lock.unlock() }
        if let existing = activeRequests[key], existing === request {
            activeRequests.removeValue(forKey: key)
        }
    }

    // MARK: - Combine Publisher
    public func requestPublisher<T: Codable>(target: APITargetType) -> AnyPublisher<BaseResponse<T>, NetworkError> {
        let cache = NetworkCache.shared
        let cacheKey = target.cacheKey
        let ttl = target.cacheTTL ?? 60 * 60
        let shouldCache = target.shouldCache

        let cachePublisher: AnyPublisher<BaseResponse<T>, NetworkError> = {
            if shouldCache, let cached: BaseResponse<T> = cache.get(cacheKey, as: BaseResponse<T>.self) {
                return Just(cached).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
            }
            return Empty().eraseToAnyPublisher()
        }()

        let networkPublisher: AnyPublisher<BaseResponse<T>, NetworkError> = Deferred {
            Future { promise in
                Task {
                    let result: APIResult<T> = await self.request(target: target)
                    switch result {
                    case .success(let response):
                        if shouldCache { cache.set(cacheKey, value: response, ttl: ttl) }
                        promise(.success(response))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()

        return cachePublisher.append(networkPublisher).eraseToAnyPublisher()
    }

    // MARK: - Async/Await Request
    public func request<T: Codable>(target: APITargetType) async -> APIResult<T> {
        // Mock mode support
        if EnvironmentsConstants.networkMode == .mock {
            let sampleData = target.sampleData
            let response = DataResponse<Data, AFError>(
                request: nil, response: nil, data: sampleData,
                metrics: nil, serializationDuration: 0, result: .success(sampleData)
            )
            try? await Task.sleep(nanoseconds: 500_000_000)
            return await self.handleResponseWithAsync(target, response: response)
        }

        // Retry loop
        var lastError: Error? = nil
        for attempt in 0...(target.retryCount) {
            do {
                var eventMonitors: [EventMonitor] = []
                #if DEBUG
                eventMonitors.append(AlamofireLogger())
                #endif

                let requestBuilder = RequestBuilder()
                let urlRequest = try requestBuilder.buildRequest(from: target)
                let session = Session(
                    serverTrustManager: serverTrustManager,
                    eventMonitors: eventMonitors
                )

                let cacheKey = target.cacheKey
                guard let request = self.tryStartRequest(key: cacheKey, method: target.method, createRequest: {
                    return session.request(urlRequest).validate(statusCode: 200..<300)
                }) as? DataRequest else {
                    return .failure(NetworkError.internalError(message: ErrorMessages.Network.requestInProgress))
                }

                let response = await request.serializingData(emptyResponseCodes: Set(200..<300)).response

                #if DEBUG
                let endTime = Date()
                BaseServiceDebugPrint.log(
                    target: target,
                    request: urlRequest,
                    response: response.response,
                    data: response.data,
                    error: response.error,
                    responseType: T.self
                )
                #endif

                self.removeRequest(key: cacheKey, request: request)
                return await self.handleResponseWithAsync(target, response: response)

            } catch let error {
                lastError = error
                if let afError = error as? AFError {
                    switch afError {
                    case .sessionTaskFailed(let urlError as URLError):
                        if urlError.code == .timedOut || urlError.code == .notConnectedToInternet {
                            if attempt < target.retryCount {
                                try? await Task.sleep(nanoseconds: UInt64(target.retryDelay * 1_000_000_000))
                                continue
                            }
                        }
                    default: break
                    }
                }
                break
            }
        }
        return await self.handleErrorWithAsync(target, response: nil, error: lastError)
    }

    // MARK: - Response Handling
    private func handleResponseWithAsync<T: Codable>(
        _ target: APITargetType,
        response: DataResponse<Data, AFError>
    ) async -> APIResult<T> {

        defer {
            Task { @MainActor in
                if response.response?.statusCode == 401 {
                    SessionManager.shared.endSession()
                }
            }
        }

        let headers = response.response?.asDictionary ?? [:]

        switch response.result {
        case .success(let data):
            do {
                if data.isEmpty {
                    if let empty = EmptyResponseDTO() as? T {
                        return .success(BaseResponse(data: empty, headers: headers))
                    }
                    if let emptyJsonData = "{}".data(using: .utf8) {
                        let decoded = try JSONDecoder().decode(T.self, from: emptyJsonData)
                        return .success(BaseResponse(data: decoded, headers: headers))
                    }
                }

                if T.self == String.self, let stringValue = String(data: data, encoding: .utf8) as? T {
                    return .success(BaseResponse(data: stringValue, headers: headers))
                }

                var decodedResponse = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
                decodedResponse.headers = headers

                if let code = decodedResponse.code, code.shouldHandle {
                    return .failure(NetworkError.serverError(errorData: BaseErrorResponse(
                        errorMessage: decodedResponse.message,
                        errorCode: String(code.rawValue),
                        headers: headers
                    )))
                }

                return .success(decodedResponse)

            } catch {
                return await self.handleErrorWithAsync(target, response: response, error: error)
            }
        case .failure(let error):
            return await self.handleErrorWithAsync(target, response: response, error: error)
        }
    }

    private func handleErrorWithAsync<T: Codable>(
        _ target: APITargetType,
        response: DataResponse<Data, AFError>? = nil,
        error: Error? = nil
    ) async -> APIResult<T> {

        let headers = response?.response?.asDictionary ?? [:]

        if let data = response?.data, let baseError = try? JSONDecoder().decode(BaseErrorResponse.self, from: data) {
            let errorWithHeaders = BaseErrorResponse(
                errorMessage: baseError.errorMessage,
                errorCode: baseError.errorCode,
                headers: headers.isEmpty ? nil : headers
            )
            return .failure(NetworkError.serverError(errorData: errorWithHeaders))
        }

        if let afError = error as? AFError {
            switch afError {
            case .sessionTaskFailed(let urlError as URLError):
                switch urlError.code {
                case .timedOut:
                    return .failure(NetworkError.internalError(message: ErrorMessages.Network.timeout))
                case .notConnectedToInternet:
                    return .failure(NetworkError.internalError(message: ErrorMessages.Network.noInternet))
                default:
                    return .failure(NetworkError.internalError(message: urlError.localizedDescription))
                }
            default:
                return .failure(NetworkError.internalError(message: afError.localizedDescription))
            }
        }

        if let error = error {
            return .failure(NetworkError.internalError(message: error.localizedDescription))
        }
        return .failure(NetworkError.internalError(message: ErrorMessages.Network.unknown))
    }
}

// MARK: - Convenience Methods
extension BaseService {
    /// Returns just the `data` field from BaseResponse
    public func requestBody<T: Codable>(target: APITargetType) async -> Result<T, NetworkError> {
        let result: APIResult<T> = await self.request(target: target)
        switch result {
        case .success(let baseResponse):
            guard let data = baseResponse.data else {
                return .failure(NetworkError.internalError(message: ErrorMessages.General.noData))
            }
            return .success(data)
        case .failure(let error):
            return .failure(error)
        }
    }

    /// For endpoints that return data directly without BaseResponse wrapper
    public func requestWithoutBaseResponse<T: Codable>(target: APITargetType) async -> Result<T, Error> {
        if EnvironmentsConstants.networkMode == .mock {
            let sampleData = target.sampleData
            do {
                let decoded = try JSONDecoder().decode(T.self, from: sampleData)
                return .success(decoded)
            } catch {
                return .failure(error)
            }
        }

        do {
            let requestBuilder = RequestBuilder()
            let urlRequest = try requestBuilder.buildRequest(from: target)
            let session = Session(serverTrustManager: serverTrustManager, eventMonitors: [])
            let response = await session.request(urlRequest)
                .validate(statusCode: 200..<300)
                .serializingData(emptyResponseCodes: Set(200..<300))
                .response

            switch response.result {
            case .success(let data):
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return .success(decoded)
            case .failure(let error):
                if let data = response.data,
                   let errorResponse = try? JSONDecoder().decode(BaseErrorResponse.self, from: data) {
                    return .failure(NetworkError.serverError(errorData: errorResponse))
                }
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }
}

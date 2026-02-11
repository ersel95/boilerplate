import Foundation

// MARK: - Network Cache
// In-memory TTL-based cache for network responses.

public protocol NetworkCacheProtocol {
    func get<T: Decodable>(_ key: String, as type: T.Type) -> T?
    func set<T: Encodable>(_ key: String, value: T, ttl: TimeInterval)
    func remove(_ key: String)
    func clear()
}

public final class NetworkCache: NetworkCacheProtocol {
    public static let shared = NetworkCache()

    private struct CacheEntry {
        let data: Data
        let expiresAt: Date
    }

    private var memoryCache: [String: CacheEntry] = [:]
    private let queue = DispatchQueue(label: "com.boilerplate.networkCache", attributes: .concurrent)

    private init() {}

    public func get<T: Decodable>(_ key: String, as type: T.Type) -> T? {
        var result: T?
        queue.sync {
            guard let entry = memoryCache[key], entry.expiresAt > Date() else {
                return
            }
            result = try? JSONDecoder().decode(T.self, from: entry.data)
        }
        return result
    }

    public func set<T: Encodable>(_ key: String, value: T, ttl: TimeInterval) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        let entry = CacheEntry(data: data, expiresAt: Date().addingTimeInterval(ttl))
        queue.async(flags: .barrier) {
            self.memoryCache[key] = entry
        }
    }

    public func remove(_ key: String) {
        queue.async(flags: .barrier) {
            self.memoryCache.removeValue(forKey: key)
        }
    }

    public func clear() {
        queue.async(flags: .barrier) {
            self.memoryCache.removeAll()
        }
    }
}

import Foundation

// MARK: - Optional Convenience Extensions

public extension Optional where Wrapped == String {
    /// Returns the wrapped string or an empty string if nil
    var orEmpty: String {
        return self ?? ""
    }
}

public extension Optional where Wrapped == Bool {
    /// Returns the wrapped bool or true if nil
    var orTrue: Bool {
        return self ?? true
    }

    /// Returns the wrapped bool or false if nil
    var orFalse: Bool {
        return self ?? false
    }
}

public extension Optional where Wrapped == Int {
    /// Returns the wrapped int or 0 if nil
    var orZero: Int {
        return self ?? 0
    }
}

public extension Optional where Wrapped == Double {
    /// Returns the wrapped double or 0.0 if nil
    var orZero: Double {
        return self ?? 0.0
    }
}

import Foundation

// MARK: - Date Formatting Extensions

public extension Date {
    /// Format date with a given format string
    func formatted(as format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }

    /// "dd.MM.yyyy"
    var dayMonthYear: String {
        formatted(as: "dd.MM.yyyy")
    }

    /// "dd.MM.yyyy HH:mm"
    var dayMonthYearTime: String {
        formatted(as: "dd.MM.yyyy HH:mm")
    }

    /// "HH:mm"
    var hourMinute: String {
        formatted(as: "HH:mm")
    }

    /// ISO 8601 format
    var iso8601: String {
        formatted(as: "yyyy-MM-dd'T'HH:mm:ssZ")
    }
}

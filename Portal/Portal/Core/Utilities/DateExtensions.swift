import Foundation

extension Date {
    var mediumDateMX: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: self)
    }
}

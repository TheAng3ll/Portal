import Foundation

enum CurrencyFormatter {
    static func usd(_ value: Decimal, fractionDigits: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: value as NSDecimalNumber) ?? "$0"
    }
}

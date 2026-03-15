import Foundation

struct PortfolioSummary {
    let totalValue: Decimal
    let totalInvested: Decimal
    let totalReturn: Decimal
    let returnPercentage: Double
    let propertyCount: Int
    
    var formattedTotalValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: totalValue as NSDecimalNumber) ?? "$0"
    }
    
    var formattedTotalReturn: String {
        let sign = returnPercentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", returnPercentage))%"
    }
    
    var isPositiveReturn: Bool {
        returnPercentage >= 0
    }
    
    var absoluteReturnValue: Decimal {
        totalValue - totalInvested
    }
}

extension PortfolioSummary {
    static var sample: PortfolioSummary {
        PortfolioSummary(
            totalValue: 1345780,
            totalInvested: 1235000,
            totalReturn: 110780,
            returnPercentage: 9.8,
            propertyCount: 3
        )
    }
}

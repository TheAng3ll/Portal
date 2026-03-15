import Foundation

struct Property: Identifiable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let city: String
    let country: String
    let imageUrl: String?
    let currentValue: Decimal
    let investedValue: Decimal
    let appreciationPercentage: Double
    let monthlyIncome: Decimal?
    
    // Nuevos campos para información detallada
    let purchaseDate: Date
    let annualYield: Double // Rendimiento anual (ej: 9.0 para 9%)
    let monthlyPayments: [MonthlyPayment] // Historial de pagos mensuales
    
    // Propiedades computadas
    var formattedCurrentValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: currentValue as NSDecimalNumber) ?? "$0"
    }
    
    var formattedInvestedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: investedValue as NSDecimalNumber) ?? "$0"
    }
    
    var formattedAppreciation: String {
        let sign = appreciationPercentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", appreciationPercentage))%"
    }
    
    var isPositiveReturn: Bool {
        appreciationPercentage >= 0
    }
    
    // Rendimiento mensual calculado (anual / 12)
    var monthlyYieldPercentage: Double {
        annualYield / 12.0
    }
    
    // Pago mensual estimado basado en el rendimiento anual
    var estimatedMonthlyYield: Decimal {
        investedValue * Decimal(annualYield / 100.0 / 12.0)
    }
    
    var formattedMonthlyYield: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: estimatedMonthlyYield as NSDecimalNumber) ?? "$0"
    }
    
    var formattedAnnualYield: String {
        return String(format: "%.1f%%", annualYield)
    }
    
    var formattedMonthlyYieldPercentage: String {
        return String(format: "%.2f%%", monthlyYieldPercentage)
    }
    
    var formattedPurchaseDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: purchaseDate)
    }
    
    // Total recibido en pagos mensuales
    var totalReceivedPayments: Decimal {
        monthlyPayments.reduce(0) { $0 + $1.amount }
    }
    
    var formattedTotalReceived: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: totalReceivedPayments as NSDecimalNumber) ?? "$0"
    }
    
    // Ganancia total = valorización + pagos recibidos
    var totalGain: Decimal {
        (currentValue - investedValue) + totalReceivedPayments
    }
    
    var totalGainPercentage: Double {
        guard investedValue > 0 else { return 0 }
        let ratio = totalGain / investedValue
        return (ratio as NSDecimalNumber).doubleValue * 100
    }
}

// MARK: - Monthly Payment Model
struct MonthlyPayment: Identifiable, Hashable {
    let id: UUID
    let month: Date
    let amount: Decimal
    let yieldPercentage: Double // Porcentaje de rendimiento aplicado ese mes
    let isPaid: Bool
    let paidDate: Date?
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
    
    var monthDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: month).capitalized
    }
}

// MARK: - Sample Data
extension Property {
    static let sampleData: [Property] = [
        Property(
            id: UUID(),
            name: "Casa Av. Principal",
            address: "Av. Principal 123",
            city: "Ciudad de México",
            country: "MX",
            imageUrl: nil,
            currentValue: 425000,
            investedValue: 380000,
            appreciationPercentage: 12.4,
            monthlyIncome: 2850,
            purchaseDate: Calendar.current.date(byAdding: .month, value: -18, to: Date()) ?? Date(),
            annualYield: 9.0,
            monthlyPayments: generateSamplePayments(investedValue: 380000, annualYield: 9.0, months: 18)
        ),
        Property(
            id: UUID(),
            name: "Departamento Centro",
            address: "Calle Centro 456",
            city: "Ciudad de México",
            country: "MX",
            imageUrl: nil,
            currentValue: 298500,
            investedValue: 275000,
            appreciationPercentage: 8.1,
            monthlyIncome: 2062,
            purchaseDate: Calendar.current.date(byAdding: .month, value: -12, to: Date()) ?? Date(),
            annualYield: 9.0,
            monthlyPayments: generateSamplePayments(investedValue: 275000, annualYield: 9.0, months: 12)
        ),
        Property(
            id: UUID(),
            name: "Oficina Las Condes",
            address: "Av. Las Condes 789",
            city: "Santiago",
            country: "CL",
            imageUrl: nil,
            currentValue: 622280,
            investedValue: 580000,
            appreciationPercentage: 8.3,
            monthlyIncome: 4350,
            purchaseDate: Calendar.current.date(byAdding: .month, value: -24, to: Date()) ?? Date(),
            annualYield: 9.0,
            monthlyPayments: generateSamplePayments(investedValue: 580000, annualYield: 9.0, months: 24)
        ),
        Property(
            id: UUID(),
            name: "Local Comercial Providencia",
            address: "Av. Providencia 2345",
            city: "Santiago",
            country: "CL",
            imageUrl: nil,
            currentValue: 512000,
            investedValue: 450000,
            appreciationPercentage: 13.8,
            monthlyIncome: 3375,
            purchaseDate: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(),
            annualYield: 9.0,
            monthlyPayments: generateSamplePayments(investedValue: 450000, annualYield: 9.0, months: 8)
        )
    ]
    
    private static func generateSamplePayments(investedValue: Decimal, annualYield: Double, months: Int) -> [MonthlyPayment] {
        let monthlyAmount = investedValue * Decimal(annualYield / 100.0 / 12.0)
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<months).map { index in
            let month = calendar.date(byAdding: .month, value: -months + index + 1, to: today) ?? today
            return MonthlyPayment(
                id: UUID(),
                month: month,
                amount: monthlyAmount,
                yieldPercentage: annualYield / 12.0,
                isPaid: true,
                paidDate: calendar.date(byAdding: .day, value: 5, to: month) // Pago el día 5 de cada mes
            )
        }
    }
}

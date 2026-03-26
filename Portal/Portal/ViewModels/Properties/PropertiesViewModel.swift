import Foundation
import SwiftUI
import Combine

@MainActor
class PropertiesViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var selectedProperty: Property?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var sortOption: SortOption = .purchaseDate

    enum SortOption: String, CaseIterable {
        case purchaseDate = "Fecha de compra"
        case currentValue = "Valor actual"
        case totalReturn = "Mayor retorno"
        case name = "Nombre"

        var iconName: String {
            switch self {
            case .purchaseDate: return "calendar"
            case .currentValue: return "dollarsign.circle"
            case .totalReturn: return "arrow.up.arrow.down"
            case .name: return "textformat"
            }
        }
    }

    var filteredProperties: [Property] {
        let filtered = searchText.isEmpty ? properties : properties.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.city.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }

        return sortedProperties(filtered)
    }

    var totalInvested: Decimal {
        properties.reduce(0) { $0 + $1.investedValue }
    }

    var totalCurrentValue: Decimal {
        properties.reduce(0) { $0 + $1.currentValue }
    }

    var totalMonthlyIncome: Decimal {
        properties.reduce(0) { $0 + ($1.monthlyIncome ?? 0) }
    }

    var totalReceivedPayments: Decimal {
        properties.reduce(0) { $0 + $1.totalReceivedPayments }
    }

    var averageAnnualYield: Double {
        guard !properties.isEmpty else { return 0 }
        return properties.reduce(0) { $0 + $1.annualYield } / Double(properties.count)
    }

    var totalGain: Decimal {
        properties.reduce(0) { $0 + $1.totalGain }
    }

    init() {
        self.properties = Property.sampleData
    }

    func loadProperties() async {
        isLoading = true
        errorMessage = nil

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        self.properties = Property.sampleData

        isLoading = false
    }

    func refreshProperties() async {
        await loadProperties()
    }

    func selectProperty(_ property: Property) {
        selectedProperty = property
    }

    func clearSelection() {
        selectedProperty = nil
    }

    private func sortedProperties(_ properties: [Property]) -> [Property] {
        switch sortOption {
        case .purchaseDate:
            return properties.sorted { $0.purchaseDate > $1.purchaseDate }
        case .currentValue:
            return properties.sorted { $0.currentValue > $1.currentValue }
        case .totalReturn:
            return properties.sorted { $0.totalGainPercentage > $1.totalGainPercentage }
        case .name:
            return properties.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }

    func formattedTotalInvested() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: totalInvested as NSDecimalNumber) ?? "$0"
    }

    func formattedTotalCurrentValue() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: totalCurrentValue as NSDecimalNumber) ?? "$0"
    }

    func formattedTotalMonthlyIncome() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: totalMonthlyIncome as NSDecimalNumber) ?? "$0"
    }

    func formattedTotalReceivedPayments() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: totalReceivedPayments as NSDecimalNumber) ?? "$0"
    }

    func formattedTotalGain() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: totalGain as NSDecimalNumber) ?? "$0"
    }
}

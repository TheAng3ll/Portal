import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var summary: PortfolioSummary = .sample
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let performanceData: [PerformancePoint] = [
        PerformancePoint(month: "Ene", value: 100),
        PerformancePoint(month: "Feb", value: 102),
        PerformancePoint(month: "Mar", value: 105),
        PerformancePoint(month: "Abr", value: 104),
        PerformancePoint(month: "May", value: 107),
        PerformancePoint(month: "Jun", value: 108),
        PerformancePoint(month: "Jul", value: 110),
        PerformancePoint(month: "Ago", value: 112),
        PerformancePoint(month: "Sep", value: 115),
        PerformancePoint(month: "Oct", value: 117),
        PerformancePoint(month: "Nov", value: 120),
        PerformancePoint(month: "Dic", value: 125)
    ]

    init() {
        self.properties = Property.sampleData
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        self.properties = Property.sampleData
        self.summary = .sample

        isLoading = false
    }

    func refreshData() async {
        await loadData()
    }
}

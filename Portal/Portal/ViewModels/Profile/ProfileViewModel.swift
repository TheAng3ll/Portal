import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var isLoading = false

    func refreshProfile() async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(nanoseconds: 300_000_000)
    }
}

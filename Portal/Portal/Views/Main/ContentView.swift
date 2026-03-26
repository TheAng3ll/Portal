import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService.shared

    var body: some View {
        Group {
            if authService.isAuthenticated {
                DashboardView()
                    .environmentObject(authService)
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}

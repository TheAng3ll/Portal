import Foundation
import SwiftUI
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: Investor?

    static let shared = AuthService()

    private let userKey = "current_user"
    /// Clave heredada; se migra una vez a `TokenManager`.
    private let legacyTokenKey = "auth_token"

    init() {
        Task { await restoreSessionIfNeeded() }
    }

    /// Restaura sesión desde Keychain (`TokenManager`) y perfil en `UserDefaults`.
    private func restoreSessionIfNeeded() async {
        await migrateLegacyTokenIfNeeded()

        guard await TokenManager.shared.accessToken != nil else {
            isAuthenticated = false
            currentUser = nil
            return
        }

        if let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(Investor.self, from: userData) {
            currentUser = user
        }
        isAuthenticated = true
    }

    private func migrateLegacyTokenIfNeeded() async {
        guard let legacy = KeychainService.shared.retrieve(key: legacyTokenKey) else { return }
        let existingRefresh = await TokenManager.shared.refreshToken
        try? await TokenManager.shared.setTokens(access: legacy, refresh: existingRefresh)
        KeychainService.shared.delete(key: legacyTokenKey)
    }

    func login(email: String, password: String) async throws {
        isAuthenticated = false
        currentUser = nil

        let response: TokenResponse = try await APIService.shared.request(
            .login(email: email, password: password)
        )
        try await TokenManager.shared.setTokens(access: response.accessToken, refresh: response.refreshToken)

        // El perfil completo puede cargarse después con `GET /api/v1/profile` cuando exista.
        let investorId = Self.userId(fromJWT: response.accessToken) ?? UUID()
        let user = Investor(
            id: investorId,
            email: email,
            firstName: "Usuario",
            lastName: "",
            phoneNumber: nil
        )
        currentUser = user
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
        isAuthenticated = true
    }

    func updateProfile(firstName: String, lastName: String, phoneNumber: String?) {
        guard var user = currentUser else { return }
        user.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        user.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        user.phoneNumber = (phone?.isEmpty == true) ? nil : phone
        currentUser = user
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
    }

    func logout() {
        Task {
            try? await APIService.shared.send(.logout)
            await TokenManager.shared.clear()
            await MainActor.run {
                UserDefaults.standard.removeObject(forKey: userKey)
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }

    /// Lee el claim `sub` (Guid del inversor) del access token JWT.
    private static func userId(fromJWT token: String) -> UUID? {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var segment = String(parts[1])
        let rem = segment.count % 4
        if rem != 0 { segment += String(repeating: "=", count: 4 - rem) }
        segment = segment.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        guard let data = Data(base64Encoded: segment),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sub = json["sub"] as? String else { return nil }
        return UUID(uuidString: sub)
    }
}

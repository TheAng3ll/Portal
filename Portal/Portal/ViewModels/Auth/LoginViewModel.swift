import Foundation
import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPassword = false

    private let authService: AuthService

    /// `authService` opcional para evitar referenciar `AuthService.shared` en el valor por defecto del parámetro (aislamiento del MainActor).
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService.shared
    }

    var canLogin: Bool {
        !email.isEmpty && !password.isEmpty && isValidEmail && password.count >= 6
    }

    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func login() async {
        guard !email.isEmpty else {
            errorMessage = "Por favor ingresa tu correo electrónico"
            return
        }

        guard isValidEmail else {
            errorMessage = "Por favor ingresa un correo válido"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Por favor ingresa tu contraseña"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.login(email: email, password: password)
        } catch {
            if let api = error as? APIError {
                errorMessage = api.errorDescription
            } else {
                errorMessage = "Credenciales incorrectas o error de red. Por favor intenta de nuevo."
            }
        }

        isLoading = false
    }

    func forgotPassword() {
        print("Recuperar contraseña para: \(email)")
    }
}

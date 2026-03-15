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
    
    init(authService: AuthService = .shared) {
        self.authService = authService
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
            try await Task.sleep(nanoseconds: 1_500_000_000)
            try await authService.login(email: email, password: password)
        } catch {
            errorMessage = "Credenciales incorrectas. Por favor intenta de nuevo."
        }
        
        isLoading = false
    }
    
    func forgotPassword() {
        // TODO: Implementar flujo de recuperación de contraseña
        print("Recuperar contraseña para: \(email)")
    }
}

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    static let shared = AuthService()
    
    private let tokenKey = "auth_token"
    private let userKey = "current_user"
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let token = KeychainService.shared.retrieve(key: tokenKey),
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func login(email: String, password: String) async throws {
        isAuthenticated = false
        currentUser = nil
        
        let user = User(
            id: UUID(),
            email: email,
            firstName: "Usuario",
            lastName: "Demo"
        )
        
        let token = "demo_token_\(UUID().uuidString)"
        
        try KeychainService.shared.save(token, key: tokenKey)
        
        let userData = try JSONEncoder().encode(user)
        UserDefaults.standard.set(userData, forKey: userKey)
        
        self.currentUser = user
        self.isAuthenticated = true
    }
    
    func logout() {
        KeychainService.shared.delete(key: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        isAuthenticated = false
        currentUser = nil
    }
}

struct User: Codable {
    let id: UUID
    let email: String
    let firstName: String
    let lastName: String
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

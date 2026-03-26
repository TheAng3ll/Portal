import Foundation

/// Gestión de tokens JWT en memoria y Keychain (acceso y refresh).
actor TokenManager {
    static let shared = TokenManager()

    private let keychain = KeychainService.shared
    private let accessKey = "portal_access_token"
    private let refreshKey = "portal_refresh_token"

    private(set) var accessToken: String?
    private(set) var refreshToken: String?

    init() {
        accessToken = keychain.retrieve(key: accessKey)
        refreshToken = keychain.retrieve(key: refreshKey)
    }

    func setTokens(access: String?, refresh: String?) throws {
        accessToken = access
        refreshToken = refresh
        if let access {
            try keychain.save(access, key: accessKey)
        } else {
            keychain.delete(key: accessKey)
        }
        if let refresh {
            try keychain.save(refresh, key: refreshKey)
        } else {
            keychain.delete(key: refreshKey)
        }
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
        keychain.delete(key: accessKey)
        keychain.delete(key: refreshKey)
    }
}

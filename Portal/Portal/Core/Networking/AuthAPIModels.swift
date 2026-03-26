import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
    let deviceId: String?

    init(email: String, password: String, deviceId: String? = nil) {
        self.email = email
        self.password = password
        self.deviceId = deviceId
    }
}

/// Coincide con `TokenResponseDto` del backend (`POST /api/v1/auth/login` y `POST /api/v1/auth/refresh`).
struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresInSeconds: Int
    let tokenType: String?
}

struct RefreshTokenRequestBody: Encodable {
    let refreshToken: String
}


struct LogoutRequestBody: Encodable {
    let refreshToken: String?
}

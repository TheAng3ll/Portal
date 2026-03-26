import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String? = nil)
    case decodingFailed(underlying: Error)
    case unauthorized
    case noRefreshToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL de API inválida."
        case .invalidResponse:
            return "Respuesta del servidor inválida."
        case .httpError(let code, let message):
            if let message, !message.isEmpty {
                return message
            }
            return "Error HTTP \(code)."
        case .decodingFailed:
            return "No se pudo interpretar la respuesta."
        case .unauthorized:
            return "Sesión no autorizada."
        case .noRefreshToken:
            return "No hay token de renovación."
        }
    }
}

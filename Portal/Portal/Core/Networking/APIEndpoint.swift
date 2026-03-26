import Foundation

enum APIEndpoint {
    case login(email: String, password: String)
    case refreshToken(token: String)
    case logout
    case getDashboard
    case getProperties
    case getPropertyDetail(id: UUID)
    case getDocuments(type: String?)
    case downloadDocument(id: UUID)
    case getProfile

    var path: String {
        switch self {
        case .login:
            return "/api/v1/auth/login"
        case .refreshToken:
            return "/api/v1/auth/refresh"
        case .logout:
            return "/api/v1/auth/logout"
        case .getDashboard:
            return "/api/v1/dashboard"
        case .getProperties:
            return "/api/v1/properties"
        case .getPropertyDetail(let id):
            return "/api/v1/properties/\(id.uuidString)"
        case .getDocuments:
            return "/api/v1/documents"
        case .downloadDocument(let id):
            return "/api/v1/documents/\(id.uuidString)/download"
        case .getProfile:
            return "/api/v1/profile"
        }
    }

    var method: String {
        switch self {
        case .login, .refreshToken, .logout:
            return "POST"
        default:
            return "GET"
        }
    }

    /// Login y refresh no deben enviar `Authorization` ni reintentar con otro refresh.
    var includesAuthorizationHeader: Bool {
        switch self {
        case .login, .refreshToken:
            return false
        default:
            return true
        }
    }

    var allowsAutomaticRefresh: Bool {
        switch self {
        case .login, .refreshToken:
            return false
        default:
            return true
        }
    }
}

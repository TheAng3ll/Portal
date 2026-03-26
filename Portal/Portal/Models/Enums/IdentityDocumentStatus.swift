import Foundation

enum IdentityDocumentStatus: String, Codable {
    case pending = "pending"
    case uploaded = "uploaded"
    case verified = "verified"
    case rejected = "rejected"

    var displayName: String {
        switch self {
        case .pending:
            return "Pendiente"
        case .uploaded:
            return "En revisión"
        case .verified:
            return "Verificado"
        case .rejected:
            return "Rechazado"
        }
    }

    var color: String {
        switch self {
        case .pending:
            return "gray"
        case .uploaded:
            return "orange"
        case .verified:
            return "green"
        case .rejected:
            return "red"
        }
    }
}

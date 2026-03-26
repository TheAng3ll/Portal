import Foundation

enum KycVerificationStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case pendingReview = "pending_review"
    case verified = "verified"
    case rejected = "rejected"

    var displayName: String {
        switch self {
        case .notStarted:
            return "No iniciado"
        case .inProgress:
            return "En progreso"
        case .pendingReview:
            return "En revisión"
        case .verified:
            return "Verificado"
        case .rejected:
            return "Rechazado"
        }
    }
}

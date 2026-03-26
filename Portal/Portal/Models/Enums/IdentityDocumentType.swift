import Foundation

enum IdentityDocumentType: String, CaseIterable, Identifiable, Codable {
    case addressProof = "address_proof"
    case ineFront = "ine_front"
    case ineBack = "ine_back"
    case taxStatus = "tax_status"
    case curp = "curp"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .addressProof:
            return "Comprobante de Domicilio"
        case .ineFront:
            return "INE - Parte Frontal"
        case .ineBack:
            return "INE - Parte Trasera"
        case .taxStatus:
            return "Constancia de Situación Fiscal"
        case .curp:
            return "CURP"
        }
    }

    var iconName: String {
        switch self {
        case .addressProof:
            return "house.fill"
        case .ineFront, .ineBack:
            return "idcard.fill"
        case .taxStatus:
            return "doc.text.fill"
        case .curp:
            return "person.text.rectangle.fill"
        }
    }

    var description: String {
        switch self {
        case .addressProof:
            return "Recibo de luz, agua, teléfono o estado de cuenta bancaria (menos a 3 meses)"
        case .ineFront:
            return "Foto clara de la parte frontal de tu INE o pasaporte"
        case .ineBack:
            return "Foto clara de la parte trasera de tu INE"
        case .taxStatus:
            return "Constancia de situación fiscal del SAT (no mayor a 3 meses)"
        case .curp:
            return "Foto o captura de pantalla de tu CURP"
        }
    }

    var acceptedFormats: [String] {
        switch self {
        case .addressProof, .taxStatus, .curp:
            return ["PDF", "JPG", "PNG"]
        case .ineFront, .ineBack:
            return ["JPG", "PNG"]
        }
    }

    var maxFileSize: Int64 {
        switch self {
        case .addressProof, .taxStatus:
            return 10 * 1024 * 1024
        case .ineFront, .ineBack, .curp:
            return 5 * 1024 * 1024
        }
    }

    var isRequired: Bool {
        true
    }
}

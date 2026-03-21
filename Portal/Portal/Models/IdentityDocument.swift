//
//  IdentityDocument.swift
//  Portal
//
//  Created by jose angel barrera alaniz on 15/03/26.
//

import Foundation

// MARK: - Tipos de Documentos de Identidad
enum IdentityDocumentType: String, CaseIterable, Identifiable, Codable {
    case addressProof = "address_proof"           // Comprobante de domicilio
    case ineFront = "ine_front"                   // INE - Parte frontal
    case ineBack = "ine_back"                     // INE - Parte trasera
    case taxStatus = "tax_status"                 // Comprobante de situación fiscal
    case curp = "curp"                            // CURP
    
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
            return 10 * 1024 * 1024  // 10 MB
        case .ineFront, .ineBack, .curp:
            return 5 * 1024 * 1024   // 5 MB
        }
    }
    
    var isRequired: Bool {
        true // Todos son requeridos para la verificación KYC
    }
}

// MARK: - Estado del Documento
enum IdentityDocumentStatus: String, Codable {
    case pending = "pending"      // Pendiente de subir
    case uploaded = "uploaded"  // Subido, pendiente de validación
    case verified = "verified"  // Verificado y aprobado
    case rejected = "rejected"    // Rechazado, necesita re-subir
    
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

// MARK: - Modelo de Documento de Identidad
struct IdentityDocument: Identifiable, Codable, Hashable {
    let id: UUID
    let type: IdentityDocumentType
    let fileName: String
    let filePath: String           // Ruta local en el dispositivo
    let fileSize: Int64
    let mimeType: String
    let status: IdentityDocumentStatus
    let uploadedAt: Date?
    let verifiedAt: Date?
    let rejectionReason: String?   // Si fue rechazado, el motivo
    let metadata: DocumentMetadata?
    
    // MARK: - Propiedades computadas
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var isUploaded: Bool {
        status != .pending
    }
    
    var isVerified: Bool {
        status == .verified
    }
    
    var fullFileUrl: URL? {
        // URL completa al archivo local
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsDirectory?.appendingPathComponent(filePath)
    }
    
    // MARK: - Inicializador
    init(
        id: UUID = UUID(),
        type: IdentityDocumentType,
        fileName: String,
        filePath: String,
        fileSize: Int64,
        mimeType: String,
        status: IdentityDocumentStatus = .pending,
        uploadedAt: Date? = nil,
        verifiedAt: Date? = nil,
        rejectionReason: String? = nil,
        metadata: DocumentMetadata? = nil
    ) {
        self.id = id
        self.type = type
        self.fileName = fileName
        self.filePath = filePath
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.status = status
        self.uploadedAt = uploadedAt
        self.verifiedAt = verifiedAt
        self.rejectionReason = rejectionReason
        self.metadata = metadata
    }
}

// MARK: - Metadatos del Documento
struct DocumentMetadata: Codable, Hashable {
    let width: Int?                // Para imágenes
    let height: Int?
    let pageCount: Int?            // Para PDFs
    let capturedAt: Date?          // Cuándo se tomó la foto
    let deviceInfo: String?         // Dispositivo usado
    let location: DocumentLocation? // Ubicación donde se capturó (opcional)
}

struct DocumentLocation: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let address: String?
}

// MARK: - Colección de Documentos del Usuario
struct UserIdentityDocuments: Codable {
    let userId: UUID
    var documents: [IdentityDocument]
    var lastUpdated: Date
    var kycStatus: KycVerificationStatus
    
    // MARK: - Verificación de completitud
    var isComplete: Bool {
        let requiredTypes = IdentityDocumentType.allCases.filter { $0.isRequired }
        let uploadedTypes = documents.filter { $0.isUploaded }.map { $0.type }
        return Set(requiredTypes).isSubset(of: Set(uploadedTypes))
    }
    
    var missingDocuments: [IdentityDocumentType] {
        let uploadedTypes = documents.filter { $0.isUploaded }.map { $0.type }
        return IdentityDocumentType.allCases.filter { $0.isRequired && !uploadedTypes.contains($0) }
    }
    
    var verifiedCount: Int {
        documents.filter { $0.isVerified }.count
    }
    
    var totalRequiredCount: Int {
        IdentityDocumentType.allCases.filter { $0.isRequired }.count
    }
    
    var progressPercentage: Double {
        guard totalRequiredCount > 0 else { return 0 }
        return Double(documents.filter { $0.isUploaded }.count) / Double(totalRequiredCount) * 100
    }
    
    // MARK: - Helpers
    func document(for type: IdentityDocumentType) -> IdentityDocument? {
        documents.first { $0.type == type }
    }
    
    mutating func updateOrAddDocument(_ document: IdentityDocument) {
        if let index = documents.firstIndex(where: { $0.type == document.type }) {
            documents[index] = document
        } else {
            documents.append(document)
        }
        lastUpdated = Date()
    }
    
    mutating func removeDocument(ofType type: IdentityDocumentType) {
        documents.removeAll { $0.type == type }
        lastUpdated = Date()
    }
}

// MARK: - Estado de Verificación KYC
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

// MARK: - Datos de Ejemplo
extension IdentityDocument {
    static var sampleDocuments: [IdentityDocument] {
        [
            IdentityDocument(
                type: .addressProof,
                fileName: "recibo_luz.pdf",
                filePath: "documents/address/recibo_luz.pdf",
                fileSize: 2_500_000,
                mimeType: "application/pdf",
                status: .verified,
                uploadedAt: Date(),
                verifiedAt: Date()
            ),
            IdentityDocument(
                type: .ineFront,
                fileName: "ine_frente.jpg",
                filePath: "documents/ine/ine_frente.jpg",
                fileSize: 3_200_000,
                mimeType: "image/jpeg",
                status: .verified,
                uploadedAt: Date(),
                verifiedAt: Date()
            ),
            IdentityDocument(
                type: .ineBack,
                fileName: "ine_reverso.jpg",
                filePath: "documents/ine/ine_reverso.jpg",
                fileSize: 2_800_000,
                mimeType: "image/jpeg",
                status: .verified,
                uploadedAt: Date(),
                verifiedAt: Date()
            ),
            IdentityDocument(
                type: .taxStatus,
                fileName: "constancia_fiscal.pdf",
                filePath: "documents/tax/constancia_fiscal.pdf",
                fileSize: 1_800_000,
                mimeType: "application/pdf",
                status: .pending
            ),
            IdentityDocument(
                type: .curp,
                fileName: "curp.jpg",
                filePath: "documents/curp/curp.jpg",
                fileSize: 1_200_000,
                mimeType: "image/jpeg",
                status: .pending
            )
        ]
    }
}

extension UserIdentityDocuments {
    static var sample: UserIdentityDocuments {
        UserIdentityDocuments(
            userId: UUID(),
            documents: IdentityDocument.sampleDocuments,
            lastUpdated: Date(),
            kycStatus: .inProgress
        )
    }
}

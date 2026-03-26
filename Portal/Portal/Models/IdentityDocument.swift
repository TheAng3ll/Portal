//
//  IdentityDocument.swift
//  Portal
//

import Foundation

struct IdentityDocument: Identifiable, Codable, Hashable {
    let id: UUID
    let type: IdentityDocumentType
    let fileName: String
    let filePath: String
    let fileSize: Int64
    let mimeType: String
    let status: IdentityDocumentStatus
    let uploadedAt: Date?
    let verifiedAt: Date?
    let rejectionReason: String?
    let metadata: DocumentMetadata?

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
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsDirectory?.appendingPathComponent(filePath)
    }

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

struct DocumentMetadata: Codable, Hashable {
    let width: Int?
    let height: Int?
    let pageCount: Int?
    let capturedAt: Date?
    let deviceInfo: String?
    let location: DocumentLocation?
}

struct DocumentLocation: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let address: String?
}

struct UserIdentityDocuments: Codable {
    let userId: UUID
    var documents: [IdentityDocument]
    var lastUpdated: Date
    var kycStatus: KycVerificationStatus

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

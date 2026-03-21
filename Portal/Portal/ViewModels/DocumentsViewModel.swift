import Foundation
import SwiftUI
import Combine

@MainActor
class DocumentsViewModel: ObservableObject {
    @Published var documents: [IdentityDocument] = []
    @Published var kycStatus: KycVerificationStatus = .notStarted
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var verifiedDocuments: [IdentityDocument] {
        documents.filter { $0.status == .verified }
    }
    
    var pendingDocuments: [IdentityDocument] {
        documents.filter { $0.status == .uploaded }
    }
    
    var rejectedDocuments: [IdentityDocument] {
        documents.filter { $0.status == .rejected }
    }
    
    var missingDocuments: [IdentityDocumentType] {
        let uploadedTypes = documents.filter { $0.isUploaded }.map { $0.type }
        return IdentityDocumentType.allCases.filter { !uploadedTypes.contains($0) }
    }
    
    var verifiedCount: Int {
        documents.filter { $0.status == .verified }.count
    }
    
    var totalRequired: Int {
        IdentityDocumentType.allCases.filter { $0.isRequired }.count
    }
    
    var progressPercentage: Double {
        guard totalRequired > 0 else { return 0 }
        let uploadedCount = documents.filter { $0.isUploaded }.count
        return Double(uploadedCount) / Double(totalRequired) * 100
    }
    
    // MARK: - Initialization
    
    init() {
        // Cargar documentos de ejemplo para preview/testing
        #if DEBUG
        self.documents = IdentityDocument.sampleDocuments
        self.kycStatus = .inProgress
        #endif
    }
    
    // MARK: - Data Loading
    
    func loadDocuments() async {
        isLoading = true
        errorMessage = nil
        
        // Simular llamada a API
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // En producción, esto vendría de la API o almacenamiento local
        self.documents = IdentityDocument.sampleDocuments
        self.updateKycStatus()
        
        isLoading = false
    }
    
    func refreshDocuments() async {
        await loadDocuments()
    }
    
    // MARK: - Document Management
    
    func addDocument(_ document: IdentityDocument) {
        if let index = documents.firstIndex(where: { $0.type == document.type }) {
            documents[index] = document
        } else {
            documents.append(document)
        }
        updateKycStatus()
    }
    
    func removeDocument(_ document: IdentityDocument) {
        documents.removeAll { $0.id == document.id }
        updateKycStatus()
    }
    
    func updateDocumentStatus(id: UUID, status: IdentityDocumentStatus, rejectionReason: String? = nil) {
        if let index = documents.firstIndex(where: { $0.id == id }) {
            let updatedDocument = documents[index]
            // Crear nuevo documento con estado actualizado
            let newDocument = IdentityDocument(
                id: updatedDocument.id,
                type: updatedDocument.type,
                fileName: updatedDocument.fileName,
                filePath: updatedDocument.filePath,
                fileSize: updatedDocument.fileSize,
                mimeType: updatedDocument.mimeType,
                status: status,
                uploadedAt: updatedDocument.uploadedAt,
                verifiedAt: status == .verified ? Date() : updatedDocument.verifiedAt,
                rejectionReason: rejectionReason,
                metadata: updatedDocument.metadata
            )
            documents[index] = newDocument
            updateKycStatus()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateKycStatus() {
        let uploadedCount = documents.filter { $0.isUploaded }.count
        let verifiedCount = documents.filter { $0.isVerified }.count
        let rejectedCount = documents.filter { $0.status == .rejected }.count
        let totalRequired = IdentityDocumentType.allCases.filter { $0.isRequired }.count
        
        if verifiedCount == totalRequired {
            kycStatus = .verified
        } else if rejectedCount > 0 && uploadedCount == 0 {
            kycStatus = .rejected
        } else if rejectedCount > 0 {
            kycStatus = .inProgress
        } else if uploadedCount > 0 && uploadedCount > verifiedCount {
            kycStatus = .pendingReview
        } else if uploadedCount > 0 {
            kycStatus = .inProgress
        } else {
            kycStatus = .notStarted
        }
    }
    
    // MARK: - Validation
    
    func canUploadDocument(ofType type: IdentityDocumentType, fileSize: Int64) -> (isValid: Bool, message: String?) {
        // Validar tamaño
        if fileSize > type.maxFileSize {
            let maxSizeMB = Double(type.maxFileSize) / (1024 * 1024)
            return (false, "El archivo excede el tamaño máximo permitido (\(String(format: "%.1f", maxSizeMB)) MB)")
        }
        
        return (true, nil)
    }
    
    // MARK: - File Storage (Local)
    
    func saveDocumentLocally(fileData: Data, type: IdentityDocumentType, fileName: String, mimeType: String) -> IdentityDocument? {
        do {
            // Crear directorio si no existe
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let documentsFolder = documentsDirectory.appendingPathComponent("documents", isDirectory: true)
            
            if !FileManager.default.fileExists(atPath: documentsFolder.path) {
                try FileManager.default.createDirectory(at: documentsFolder, withIntermediateDirectories: true)
            }
            
            // Crear subcarpeta según tipo
            let typeFolder = documentsFolder.appendingPathComponent(type.rawValue, isDirectory: true)
            if !FileManager.default.fileExists(atPath: typeFolder.path) {
                try FileManager.default.createDirectory(at: typeFolder, withIntermediateDirectories: true)
            }
            
            // Guardar archivo
            let fileURL = typeFolder.appendingPathComponent(fileName)
            try fileData.write(to: fileURL)
            
            // Crear documento
            let document = IdentityDocument(
                type: type,
                fileName: fileName,
                filePath: "documents/\(type.rawValue)/\(fileName)",
                fileSize: Int64(fileData.count),
                mimeType: mimeType,
                status: .uploaded,
                uploadedAt: Date()
            )
            
            // Agregar a la lista
            addDocument(document)
            
            return document
            
        } catch {
            errorMessage = "Error guardando documento: \(error.localizedDescription)"
            return nil
        }
    }
    
    func deleteDocumentLocally(_ document: IdentityDocument) -> Bool {
        do {
            if let fileURL = document.fullFileUrl {
                try FileManager.default.removeItem(at: fileURL)
            }
            removeDocument(document)
            return true
        } catch {
            errorMessage = "Error eliminando documento: \(error.localizedDescription)"
            return false
        }
    }
}

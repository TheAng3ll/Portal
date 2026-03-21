import SwiftUI

struct DocumentDetailView: View {
    let document: IdentityDocument
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showRejectionReason = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header con icono grande
                    headerSection
                    
                    // Estado del documento
                    statusSection
                    
                    // Información del archivo
                    fileInfoSection
                    
                    // Preview placeholder
                    previewSection
                    
                    // Botones de acción
                    actionButtonsSection
                    
                    // Si fue rechazado, mostrar motivo
                    if document.status == .rejected, let reason = document.rejectionReason {
                        rejectionReasonSection(reason: reason)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(document.type.displayName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                            showDeleteConfirmation = true
                        }) {
                            Label("Eliminar Documento", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .confirmationDialog("¿Eliminar documento?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Eliminar", role: .destructive) {
                    // Acción de eliminar
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Esta acción no se puede deshacer. El documento será eliminado permanentemente.")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: document.type.iconName)
                    .font(.system(size: 48))
                    .foregroundStyle(statusColor)
            }
            
            VStack(spacing: 8) {
                Text(document.type.displayName)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    
                Text(document.type.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.top)
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: statusIcon)
                    .font(.title3)
                    .foregroundStyle(statusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estado")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(document.status.displayName)
                        .font(.headline)
                        .foregroundStyle(statusColor)
                }
                
                Spacer()
                
                // Fecha según estado
                if let verifiedAt = document.verifiedAt, document.status == .verified {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Verificado el")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatDate(verifiedAt))
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                } else if let uploadedAt = document.uploadedAt {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(document.status == .uploaded ? "Enviado el" : "Subido el")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatDate(uploadedAt))
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - File Info Section
    private var fileInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Información del Archivo")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                InfoRow(title: "Nombre", value: document.fileName)
                Divider().padding(.leading, 16)
                
                InfoRow(title: "Formato", value: document.mimeType.uppercased())
                Divider().padding(.leading, 16)
                
                InfoRow(title: "Tamaño", value: document.formattedFileSize)
                Divider().padding(.leading, 16)
                
                InfoRow(
                    title: "Ubicación",
                    value: document.fullFileUrl?.path ?? "Almacenamiento local"
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vista Previa")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(height: 300)
                
                if document.isImage {
                    // Placeholder para imagen
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray.opacity(0.5))
                        
                        Text("Imagen del documento")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button(action: {
                            // Abrir preview
                        }) {
                            Label("Ver Documento", systemImage: "eye")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                } else if document.isPDF {
                    // Placeholder para PDF
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray.opacity(0.5))
                        
                        Text("Documento PDF")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button(action: {
                            // Abrir PDF
                        }) {
                            Label("Ver PDF", systemImage: "eye")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Botón principal según estado
            switch document.status {
            case .pending:
                Button(action: {
                    // Subir documento
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Subir Documento")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
            case .rejected:
                Button(action: {
                    // Re-subir documento
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                        Text("Volver a Subir")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button(action: {
                    showRejectionReason = true
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                        Text("Ver Motivo del Rechazo")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
            case .uploaded, .verified:
                HStack(spacing: 12) {
                    Button(action: {
                        // Descargar
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.circle")
                            Text("Descargar")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Compartir
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Compartir")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Rejection Reason Section
    private func rejectionReasonSection(reason: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                
                Text("Motivo del Rechazo")
                    .font(.headline)
                    .foregroundStyle(.red)
            }
            
            Text(reason)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.05))
                .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                .fill(Color.red.opacity(0.05))
        )
        .padding(.horizontal)
    }
    
    // MARK: - Helper Properties
    private var statusColor: Color {
        switch document.status {
        case .verified:
            return .green
        case .rejected:
            return .red
        case .uploaded:
            return .orange
        case .pending:
            return .gray
        }
    }
    
    private var statusIcon: String {
        switch document.status {
        case .verified:
            return "checkmark.seal.fill"
        case .rejected:
            return "xmark.octagon.fill"
        case .uploaded:
            return "clock.fill"
        case .pending:
            return "doc.badge.plus"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Extensiones
extension IdentityDocument {
    var isImage: Bool {
        mimeType.hasPrefix("image/")
    }
    
    var isPDF: Bool {
        mimeType == "application/pdf"
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DocumentDetailView(document: IdentityDocument.sampleDocuments[0])
    }
}

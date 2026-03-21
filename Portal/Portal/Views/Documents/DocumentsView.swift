import SwiftUI

struct DocumentsView: View {
    @StateObject private var viewModel = DocumentsViewModel()
    @State private var selectedDocument: IdentityDocument?
    @State private var showDocumentPicker = false
    @State private var documentTypeToUpload: IdentityDocumentType?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header con progreso
                    headerSection
                    
                    // Resumen KYC
                    kycStatusSection
                    
                    // Progreso visual
                    progressSection
                    
                    // Documentos faltantes (si aplica)
                    if !viewModel.missingDocuments.isEmpty {
                        missingDocumentsSection
                    }
                    
                    // Lista de documentos por estado
                    documentsListSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Documentos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .sheet(item: $selectedDocument) { document in
                DocumentDetailView(document: document)
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentTypePickerView { selectedType in
                    documentTypeToUpload = selectedType
                    showDocumentPicker = false
                    // Aquí se manejaría la subida del documento
                }
            }
            .task {
                await viewModel.loadDocuments()
            }
            .refreshable {
                await viewModel.refreshDocuments()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verificación de Identidad")
                .font(.title2.bold())
                .foregroundStyle(.primary)
            
            Text("Para completar tu registro, necesitamos verificar tu identidad con los siguientes documentos.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
        }
        .padding(.horizontal)
    }
    
    // MARK: - KYC Status Section
    private var kycStatusSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: statusIcon)
                        .font(.title2)
                        .foregroundStyle(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estado de Verificación")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.kycStatus.displayName)
                        .font(.headline)
                        .foregroundStyle(statusColor)
                    
                    Text("\(viewModel.verifiedCount) de \(viewModel.totalRequired) documentos verificados")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal)
            
            // Mensaje según estado
            if viewModel.kycStatus == .notStarted {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.orange)
                    
                    Text("Sube tus documentos para comenzar la verificación")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            } else if viewModel.kycStatus == .inProgress {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.orange)
                    
                    Text("Estamos revisando tus documentos. Esto puede tomar hasta 24 horas.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            } else if viewModel.kycStatus == .verified {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    
                    Text("¡Tu identidad ha sido verificada correctamente!")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progreso")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(Int(viewModel.progressPercentage))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal)
            
            // Barra de progreso
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.orange, .orange.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(viewModel.progressPercentage / 100), height: 12)
                }
            }
            .frame(height: 12)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Missing Documents Section
    private var missingDocumentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                
                Text("Documentos Faltantes")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(viewModel.missingDocuments.count) pendientes")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(viewModel.missingDocuments) { type in
                    MissingDocumentRow(type: type) {
                        documentTypeToUpload = type
                        // Acción para subir este documento específico
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Documents List Section
    private var documentsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Todos los Documentos")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(viewModel.documents.count) de \(viewModel.totalRequired)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            // Agrupados por estado
            if !viewModel.verifiedDocuments.isEmpty {
                DocumentsSection(
                    title: "Verificados",
                    icon: "checkmark.seal.fill",
                    color: .green,
                    documents: viewModel.verifiedDocuments
                ) { document in
                    selectedDocument = document
                }
            }
            
            if !viewModel.pendingDocuments.isEmpty {
                DocumentsSection(
                    title: "En Revisión",
                    icon: "clock.fill",
                    color: .orange,
                    documents: viewModel.pendingDocuments
                ) { document in
                    selectedDocument = document
                }
            }
            
            if !viewModel.rejectedDocuments.isEmpty {
                DocumentsSection(
                    title: "Rechazados",
                    icon: "exclamationmark.triangle.fill",
                    color: .red,
                    documents: viewModel.rejectedDocuments
                ) { document in
                    selectedDocument = document
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    private var statusColor: Color {
        switch viewModel.kycStatus {
        case .verified:
            return .green
        case .rejected:
            return .red
        case .inProgress, .pendingReview:
            return .orange
        case .notStarted:
            return .gray
        }
    }
    
    private var statusIcon: String {
        switch viewModel.kycStatus {
        case .verified:
            return "checkmark.seal.fill"
        case .rejected:
            return "xmark.octagon.fill"
        case .pendingReview:
            return "clock.fill"
        case .inProgress:
            return "arrow.clockwise"
        case .notStarted:
            return "doc.questionmark.fill"
        }
    }
}

// MARK: - Missing Document Row
struct MissingDocumentRow: View {
    let type: IdentityDocumentType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: type.iconName)
                        .font(.title3)
                        .foregroundStyle(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    
                    Text("Requerido")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Documents Section
struct DocumentsSection: View {
    let title: String
    let icon: String
    let color: Color
    let documents: [IdentityDocument]
    let onSelect: (IdentityDocument) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(color)
                
                Spacer()
                
                Text("\(documents.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(documents) { document in
                    Button(action: {
                        onSelect(document)
                    }) {
                        DocumentRowView(document: document)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Document Row View
struct DocumentRowView: View {
    let document: IdentityDocument
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(statusColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: document.type.iconName)
                    .font(.title3)
                    .foregroundStyle(statusColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(document.type.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    Text(document.formattedFileSize)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let uploadedAt = document.uploadedAt {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(formatDate(uploadedAt))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Status indicator
            if document.isVerified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            } else if document.status == .rejected {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
}

// MARK: - Document Type Picker View
struct DocumentTypePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (IdentityDocumentType) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section("Selecciona el tipo de documento") {
                    ForEach(IdentityDocumentType.allCases) { type in
                        Button(action: {
                            onSelect(type)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: type.iconName)
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(type.displayName)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.primary)
                                    
                                    Text(type.acceptedFormats.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                        }
                    }
                }
                
                Section {
                    Text("Los archivos deben ser legibles y estar completos. Tamaño máximo: 10 MB para PDFs, 5 MB para imágenes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Tipo de Documento")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DocumentsView()
}

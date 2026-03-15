import SwiftUI

struct PropertiesListView: View {
    @StateObject private var viewModel = PropertiesViewModel()
    @State private var showSortOptions = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con título
                    headerSection
                    
                    // Resumen del portafolio
                    portfolioSummarySection
                    
                    // Barra de búsqueda y filtros
                    searchAndFilterSection
                    
                    // Lista de propiedades
                    propertiesListSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Propiedades")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSortOptions = true
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .confirmationDialog("Ordenar por", isPresented: $showSortOptions, titleVisibility: .visible) {
                ForEach(PropertiesViewModel.SortOption.allCases, id: \.self) { option in
                    Button(option.rawValue) {
                        viewModel.sortOption = option
                    }
                }
                Button("Cancelar", role: .cancel) { }
            }
            .sheet(item: $viewModel.selectedProperty) { property in
                PropertyDetailView(property: property)
            }
            .task {
                await viewModel.loadProperties()
            }
            .refreshable {
                await viewModel.refreshProperties()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tus Inversiones")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                
                Text("\(viewModel.properties.count) propiedades en tu portafolio")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Portfolio Summary Section
    private var portfolioSummarySection: some View {
        VStack(spacing: 16) {
            // Card principal con valor total
            VStack(spacing: 12) {
                Text("Valor Total del Portafolio")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(viewModel.formattedTotalCurrentValue())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("USD")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Badge de ganancia total
                let totalReturn = viewModel.totalGain
                let ratio = viewModel.totalInvested > 0 ? totalReturn / viewModel.totalInvested : Decimal(0)
                let returnPercentage = (ratio as NSDecimalNumber).doubleValue * 100
                
                HStack(spacing: 4) {
                    Image(systemName: totalReturn >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    
                    Text("\(String(format: "%.1f", returnPercentage))%")
                        .font(.subheadline.bold())
                    
                    Text("Retorno Total")
                        .font(.caption)
                }
                .foregroundStyle(totalReturn >= 0 ? .green : .red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(totalReturn >= 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                )
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal)
            
            // Grid de métricas
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MetricCard(
                    title: "Invertido",
                    value: viewModel.formattedTotalInvested(),
                    icon: "dollarsign.circle",
                    color: .blue
                )
                
                MetricCard(
                    title: "Pagos Recibidos",
                    value: viewModel.formattedTotalReceivedPayments(),
                    icon: "arrow.down.circle",
                    color: .green
                )
                
                MetricCard(
                    title: "Rendimiento Anual",
                    value: String(format: "%.1f%%", viewModel.averageAnnualYield),
                    icon: "percent",
                    color: .orange
                )
                
                MetricCard(
                    title: "Ingreso Mensual",
                    value: viewModel.formattedTotalMonthlyIncome(),
                    icon: "calendar.badge.clock",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Buscar propiedades...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal)
            
            // Filtro activo
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundStyle(.orange)
                
                Text("Ordenado por: \(viewModel.sortOption.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Properties List Section
    private var propertiesListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(viewModel.filteredProperties.count) Propiedades")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if viewModel.filteredProperties.isEmpty {
                EmptyStateView(
                    icon: "building.2",
                    title: "No se encontraron propiedades",
                    message: "Intenta con otra búsqueda o revisa más tarde"
                )
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.filteredProperties) { property in
                        Button(action: {
                            viewModel.selectProperty(property)
                        }) {
                            PropertyRowView(property: property)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Metric Card Component
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.5))
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
}

#Preview {
    PropertiesListView()
}

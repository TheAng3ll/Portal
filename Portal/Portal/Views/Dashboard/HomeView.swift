import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            dashboardContent
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(0)
            
            PropertiesListView()
                .tabItem {
                    Label("Propiedades", systemImage: "building.2.fill")
                }
                .tag(1)
            
            DocumentsView()
                .tabItem {
                    Label("Documentos", systemImage: "doc.text.fill")
                }
                .tag(2)
            
            profileView
                .tabItem {
                    Label("Mi Perfil", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.orange)
    }
    
    private var dashboardContent: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con logo
                    headerView
                    
                    // Resumen de inversión
                    TotalValueCard(summary: viewModel.summary)
                    
                    // Gráfica de rendimiento
                    PerformanceChartView(data: viewModel.performanceData)
                    
                    // Listado de propiedades
                    propertiesSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "figure.run.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                Text("Arquímedes")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Button(action: {
                selectedTab = 3
            }) {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(.gray)
                    )
            }
        }
        .padding(.horizontal)
    }
    
    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tus Propiedades")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    selectedTab = 1
                }) {
                    Text("Ver todas (\(viewModel.properties.count))")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.properties) { property in
                    NavigationLink(value: property) {
                        PropertyCard(property: property)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var profileView: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundStyle(.orange)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.currentUser?.fullName ?? "Usuario")
                                .font(.headline)
                            
                            Text(authService.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Configuración") {
                    NavigationLink(destination: Text("Editar Perfil")) {
                        Label("Editar Perfil", systemImage: "person.crop.circle")
                    }
                    
                    NavigationLink(destination: Text("Notificaciones")) {
                        Label("Notificaciones", systemImage: "bell")
                    }
                    
                    NavigationLink(destination: Text("Seguridad")) {
                        Label("Seguridad", systemImage: "lock.shield")
                    }
                }
                
                Section("Soporte") {
                    NavigationLink(destination: Text("Ayuda")) {
                        Label("Centro de Ayuda", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: Text("Contacto")) {
                        Label("Contactar Soporte", systemImage: "envelope")
                    }
                }
                
                Section {
                    Button(action: {
                        authService.logout()
                    }) {
                        Label("Cerrar Sesión", systemImage: "arrow.right.square")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Perfil")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthService.shared)
}

import SwiftUI

struct DashboardView: View {
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

            ProfileView()
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
                    headerView

                    TotalValueCard(summary: viewModel.summary)

                    PerformanceChartView(data: viewModel.performanceData)

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
}

#Preview {
    DashboardView()
        .environmentObject(AuthService.shared)
}

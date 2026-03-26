import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    identityCard

                    ProfileSectionHeader(title: "Configuración")
                    VStack(spacing: 0) {
                        navRow(
                            title: "Editar Perfil",
                            icon: "person.crop.circle.fill",
                            destination: EditProfileView()
                        )
                        Divider().padding(.leading, 44)
                        navRow(
                            title: "Notificaciones",
                            icon: "bell.fill",
                            destination: NotificationSettingsView()
                        )
                        Divider().padding(.leading, 44)
                        navRow(
                            title: "Seguridad",
                            icon: "lock.shield.fill",
                            destination: SecuritySettingsView()
                        )
                    }
                    .profileSettingsCard()

                    ProfileSectionHeader(title: "Soporte")
                    VStack(spacing: 0) {
                        navRow(
                            title: "Centro de Ayuda",
                            icon: "questionmark.circle.fill",
                            destination: Text("Centro de Ayuda")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemGroupedBackground))
                                .navigationTitle("Ayuda")
                        )
                        Divider().padding(.leading, 44)
                        navRow(
                            title: "Contactar Soporte",
                            icon: "envelope.fill",
                            destination: Text("Contactar Soporte")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemGroupedBackground))
                                .navigationTitle("Soporte")
                        )
                    }
                    .profileSettingsCard()

                    Button(action: { authService.logout() }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Cerrar Sesión")
                            Spacer()
                        }
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color(red: 0.9, green: 0.35, blue: 0.25))
                        .profileSettingsCard()
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var identityCard: some View {
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

            Spacer(minLength: 0)
        }
        .profileSettingsCard()
    }

    private func navRow<Destination: View>(
        title: String,
        icon: String,
        destination: Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(.orange)
                    .frame(width: 28, alignment: .center)

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService.shared)
}

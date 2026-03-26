import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("portal.notifications.push") private var pushEnabled = true
    @AppStorage("portal.notifications.email") private var emailEnabled = true
    @AppStorage("portal.notifications.documents") private var documentReminders = true
    @AppStorage("portal.notifications.portfolio") private var portfolioUpdates = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProfileSectionHeader(title: "Canales")

                VStack(spacing: 0) {
                    toggleRow(
                        title: "Notificaciones push",
                        subtitle: "Alertas en el dispositivo",
                        icon: "iphone.radiowaves.left.and.right",
                        isOn: $pushEnabled
                    )
                    Divider().padding(.leading, 44)
                    toggleRow(
                        title: "Correo electrónico",
                        subtitle: "Resúmenes y avisos por email",
                        icon: "envelope.fill",
                        isOn: $emailEnabled
                    )
                }
                .profileSettingsCard()

                ProfileSectionHeader(title: "Contenido")

                VStack(spacing: 0) {
                    toggleRow(
                        title: "Recordatorios de documentos",
                        subtitle: "Vencimientos y solicitudes pendientes",
                        icon: "doc.text.fill",
                        isOn: $documentReminders
                    )
                    Divider().padding(.leading, 44)
                    toggleRow(
                        title: "Novedades del portafolio",
                        subtitle: "Cambios de valor y noticias relevantes",
                        icon: "chart.line.uptrend.xyaxis",
                        isOn: $portfolioUpdates
                    )
                }
                .profileSettingsCard()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleRow(
        title: String,
        subtitle: String,
        icon: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.orange)
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.orange)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}

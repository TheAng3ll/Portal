import SwiftUI

struct SecuritySettingsView: View {
    @AppStorage("portal.security.biometricApp") private var biometricForApp = true
    @AppStorage("portal.security.twoFactor") private var twoFactorEnabled = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProfileSectionHeader(title: "Acceso")

                VStack(spacing: 0) {
                    toggleRow(
                        title: "Face ID / Touch ID",
                        subtitle: "Desbloquear la app con biometría",
                        icon: "faceid",
                        isOn: $biometricForApp
                    )
                    Divider().padding(.leading, 44)
                    toggleRow(
                        title: "Autenticación en dos pasos",
                        subtitle: "Capa extra al iniciar sesión",
                        icon: "checkmark.shield.fill",
                        isOn: $twoFactorEnabled
                    )
                }
                .profileSettingsCard()

                ProfileSectionHeader(title: "Contraseña")

                NavigationLink {
                    ChangePasswordView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .font(.body)
                            .foregroundStyle(.orange)
                            .frame(width: 28, alignment: .center)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cambiar contraseña")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("Actualiza tu clave de acceso")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 10)
                    .profileSettingsCard()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Seguridad")
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

struct ChangePasswordView: View {
    @State private var current = ""
    @State private var newPassword = ""
    @State private var confirm = ""
    @State private var showNotice = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProfileSectionHeader(title: "Nueva clave")

                VStack(alignment: .leading, spacing: 16) {
                    secureField(title: "Contraseña actual", text: $current)
                    secureField(title: "Nueva contraseña", text: $newPassword)
                    secureField(title: "Confirmar contraseña", text: $confirm)
                }
                .profileSettingsCard()

                Button(action: { showNotice = true }) {
                    Text("Actualizar contraseña")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1 : 0.45)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Cambiar contraseña")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Integración pendiente", isPresented: $showNotice) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Esta acción requiere el API de autenticación. Los campos son solo de demostración.")
        }
    }

    private var canSubmit: Bool {
        !current.isEmpty && newPassword.count >= 8 && newPassword == confirm
    }

    private func secureField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            SecureField("", text: text)
                .textContentType(.password)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview("Seguridad") {
    NavigationStack {
        SecuritySettingsView()
    }
}

#Preview("Contraseña") {
    NavigationStack {
        ChangePasswordView()
    }
}

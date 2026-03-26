import SwiftUI
import UIKit

struct EditProfileView: View {
    @EnvironmentObject var authService: AuthService

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var showSaved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProfileSectionHeader(title: "Datos personales")

                VStack(alignment: .leading, spacing: 16) {
                    profileField(title: "Nombre", text: $firstName, contentType: .givenName)
                    profileField(title: "Apellidos", text: $lastName, contentType: .familyName)
                    profileField(title: "Teléfono", text: $phone, keyboard: .phonePad, contentType: .telephoneNumber)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Correo electrónico")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(authService.currentUser?.email ?? "")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .profileSettingsCard()

                Button(action: save) {
                    Text("Guardar cambios")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.45)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Editar Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            syncFromUser()
        }
        .alert("Cambios guardados", isPresented: $showSaved) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Tu información se ha actualizado.")
        }
    }

    private var canSave: Bool {
        let f = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let l = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !f.isEmpty && !l.isEmpty
    }

    private func syncFromUser() {
        guard let u = authService.currentUser else { return }
        firstName = u.firstName
        lastName = u.lastName
        phone = u.phoneNumber ?? ""
    }

    private func save() {
        authService.updateProfile(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phone.isEmpty ? nil : phone
        )
        showSaved = true
    }

    private func profileField(
        title: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("", text: text)
                .modifier(OptionalTextContentType(contentType: contentType))
                .keyboardType(keyboard)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct OptionalTextContentType: ViewModifier {
    let contentType: UITextContentType?

    func body(content: Content) -> some View {
        if let type = contentType {
            content.textContentType(type)
        } else {
            content
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .environmentObject(AuthService.shared)
    }
}

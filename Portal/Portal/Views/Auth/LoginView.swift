import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                // Decoración lateral izquierda (gradiente naranja/verde)
                HStack {
                    GeometryReader { _ in
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.orange.opacity(0.4),
                                            Color.orange.opacity(0.2),
                                            Color.clear
                                        ],
                                        startPoint: .topTrailing,
                                        endPoint: .bottomLeading
                                    )
                                )
                                .frame(width: 300, height: 300)
                                .offset(x: -80, y: 100)
                                .blur(radius: 40)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.green.opacity(0.3),
                                            Color.green.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .center,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 250, height: 250)
                                .offset(x: -60, y: 350)
                                .blur(radius: 35)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.orange.opacity(0.3),
                                            Color.orange.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 200, height: 200)
                                .offset(x: -40, y: 600)
                                .blur(radius: 30)
                        }
                    }
                    .frame(width: geometry.size.width * 0.4)
                    
                    Spacer()
                }
                
                // Logo Arquímedes
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        
                        Text("Arquímedes")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)
                    .padding(.leading, 40)
                    
                    Spacer()
                }
                
                // Card de Login centrada
                VStack {
                    Spacer()
                    
                    loginCard
                        .frame(maxWidth: 380)
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    private var loginCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Título
            Text("Login")
                .font(.title2.bold())
                .foregroundStyle(.primary)
            
            // Campos de entrada
            VStack(alignment: .leading, spacing: 16) {
                // Email
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextField("", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.yellow.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                // Contraseña
                VStack(alignment: .leading, spacing: 6) {
                    Text("Contraseña")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        if viewModel.showPassword {
                            TextField("", text: $viewModel.password)
                                .textContentType(.password)
                        } else {
                            SecureField("", text: $viewModel.password)
                                .textContentType(.password)
                        }
                        
                        Spacer()
                        
                        // Iconos de seguridad (simulando los del ERP)
                        HStack(spacing: 8) {
                            Image(systemName: "key.fill")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            
                            Button(action: {
                                viewModel.showPassword.toggle()
                            }) {
                                Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.yellow.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            
            // Olvidé mi contraseña
            Button(action: {
                viewModel.forgotPassword()
            }) {
                Text("Olvidé mi contraseña")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            
            // Mensaje de error
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            
            // Botón Login
            Button(action: {
                Task {
                    await viewModel.login()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.orange)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Login")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                    }
                }
                .frame(height: 44)
            }
            .disabled(!viewModel.canLogin || viewModel.isLoading)
            .opacity(viewModel.canLogin ? 1.0 : 0.6)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
    }
}

#Preview {
    LoginView()
}

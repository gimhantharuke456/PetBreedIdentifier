import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToHome: Bool = false
    
    private let authService = AuthenticationService.shared
    private let userService = UserService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                Text("Welcome Back")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                // Form Fields
                VStack(spacing: 16) {
                    CustomTextField(
                        placeholder: "Email",
                        text: $email
                    )
                    
                    CustomTextField(
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                }
                .padding(.horizontal)
                
                // Login Button
                CustomButton(
                    title: "Login",
                    action: handleLogin,
                    isDisabled: email.isEmpty || password.isEmpty || isLoading
                )
                .padding(.horizontal)
                
                // Register Navigation
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    
                    NavigationLink("Register") {
                        RegisterView()
                    }
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func handleLogin() {
        isLoading = true
        
        Task {
            do {
                // Sign in with Firebase Auth
                let firebaseUser = try await authService.signIn(email: email, password: password)
                
                // Get user from Firestore
                let user = try await userService.getUser(userId: firebaseUser.uid)
                
                // Update UI on main thread
                await MainActor.run {
                    isLoading = false
                    navigateToHome = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// Preview
#Preview {
    LoginView()
}

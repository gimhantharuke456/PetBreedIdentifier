import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var petName: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToHome: Bool = false
    
    private let authService = AuthenticationService.shared
    private let userService = UserService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    CustomTextField(
                        placeholder: "Name",
                        text: $name
                    )
                    
                    CustomTextField(
                        placeholder: "Email",
                        text: $email
                    )
                    
                    CustomTextField(
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                    
                    CustomTextField(
                        placeholder: "Pet Name",
                        text: $petName
                    )
                }
                .padding(.horizontal)
                
                CustomButton(
                    title: "Register",
                    action: handleRegister,
                    isDisabled: email.isEmpty || password.isEmpty || name.isEmpty || petName.isEmpty || isLoading
                )
                .padding(.horizontal)
                
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    
                    Button("Login") {
                        dismiss()
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
    
    private func handleRegister() {
        isLoading = true
        
        Task {
            do {
                // Create Firebase Auth user
                let firebaseUser = try await authService.signUp(email: email, password: password)
                
                // Create Firestore user
                let newUser = AppUser(
                    id: firebaseUser.uid,
                    name: name,
                    email: email,
                    petName: petName,
                    petImageURL: "", // You can add image upload functionality later
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                try await userService.createUser(newUser)
                
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

#Preview {
    RegisterView()
}

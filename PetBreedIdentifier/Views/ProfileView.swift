import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var petName: String = ""
    @State private var isEditing: Bool = false
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showDeleteConfirmation: Bool = false
    @State private var navigateToLogin: Bool = false
    @State private var currentUser: AppUser?
    
    private let authService = AuthenticationService.shared
    private let userService = UserService()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Image Section
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay {
                            if let email = currentUser?.email {
                                Text(String(email.prefix(1)).uppercased())
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top)
                    
                    // User Info Section
                    VStack(spacing: 16) {
                        if isEditing {
                            CustomTextField(
                                placeholder: "Name",
                                text: $name
                            )
                            
                            CustomTextField(
                                placeholder: "Pet Name",
                                text: $petName
                            )
                        } else {
                            infoRow(title: "Name", value: name)
                            infoRow(title: "Email", value: currentUser?.email ?? "")
                            infoRow(title: "Pet Name", value: petName)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if isEditing {
                            CustomButton(
                                title: "Save Changes",
                                action: handleUpdateProfile,
                                isDisabled: name.isEmpty || petName.isEmpty || isLoading
                            )
                            
                            CustomButton(
                                title: "Cancel",
                                action: { isEditing = false }
                            )
                        } else {
                            CustomButton(
                                title: "Edit Profile",
                                action: { isEditing = true }
                            )
                        }
                        
                        CustomButton(
                            title: "Sign Out",
                            action: handleSignOut
                        )
                        
                        CustomButton(
                            title: "Delete Account",
                            action: { showDeleteConfirmation = true }
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarBackButtonHidden(isEditing)
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
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    handleDeleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
            .task {
                await loadUserProfile()
            }
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    private func loadUserProfile() async {
        guard let userId = authService.currentUser?.uid else { return }
        
        do {
            let user = try await userService.getUser(userId: userId)
            await MainActor.run {
                self.currentUser = user
                self.name = user.name
                self.petName = user.petName
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load profile: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func handleUpdateProfile() {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        
        Task {
            do {
                let updatedUser = AppUser(
                    id: userId,
                    name: name,
                    email: currentUser?.email ?? "",
                    petName: petName,
                    petImageURL: currentUser?.petImageURL ?? "",
                    createdAt: currentUser?.createdAt ?? Date(),
                    updatedAt: Date()
                )
                
                try await userService.updateUser(updatedUser)
                
                await MainActor.run {
                    isLoading = false
                    isEditing = false
                    currentUser = updatedUser
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
    
    private func handleSignOut() {
        Task {
            do {
                try authService.signOut()
                navigateToLogin = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func handleDeleteAccount() {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        
        Task {
            do {
                // Delete from Firestore
                try await userService.deleteUser(userId: userId)
                
                // Delete from Firebase Auth
                try await authService.currentUser?.delete()
                
                await MainActor.run {
                    isLoading = false
                    navigateToLogin = true
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
    ProfileView()
}

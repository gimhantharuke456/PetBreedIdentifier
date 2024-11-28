import SwiftUI
import FirebaseAuth


struct EditPostView: View {
    let postId: String
    @Binding var editedCaption: String
    @Binding var editSheetIsPresented: Bool
    @StateObject private var viewModel = EditPostViewModel()
    @State private var localCaption: String = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Caption")) {
                    TextEditor(text: $localCaption)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        editSheetIsPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            do {
                                try await viewModel.updatePostCaption(postId: postId, newCaption: localCaption)
                                editedCaption = localCaption
                                editSheetIsPresented = false
                            } catch {
                                errorMessage = error.localizedDescription
                                showErrorAlert = true
                            }
                        }
                    }
                    .disabled(localCaption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Update Failed"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            localCaption = editedCaption
        }
    }
}

class EditPostViewModel: ObservableObject {
    private let postService = PostService()
    
    func updatePostCaption(postId: String, newCaption: String) async throws {
        // Validate the caption
        guard !newCaption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "EditPostError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Caption cannot be empty"])
        }
        
        // Ensure the user is authenticated
        guard let _ = Auth.auth().currentUser else {
            throw NSError(domain: "AuthError", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Call the update method in the PostService
        try await postService.updatePostCaption(postId: postId, newCaption: newCaption)
    }
}


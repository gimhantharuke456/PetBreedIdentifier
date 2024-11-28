import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

struct HomeContentView: View {
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    @State private var caption: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Image Picker
            PhotosPicker(selection: $selectedImage) {
                if let selectedUIImage {
                    Image(uiImage: selectedUIImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                }
            }
            
            // Caption TextField
            CustomTextArea(
                placeholder: "Write a caption...",
                text: $caption
                )
               
                .padding(.horizontal)
            
            // Post Button
            Button(action: createPost) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Post")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(isLoading || selectedUIImage == nil || caption.isEmpty)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Create Post")
        .onChange(of: selectedImage) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedUIImage = uiImage
                }
            }
        }
        .alert("Message", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func createPost() {
        guard let image = selectedUIImage,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        Task {
            do {
                // 1. Upload image to Firebase Storage
                let imageUrl = try await uploadImage(image)
                
                // 2. Get user details
                let user = try await UserService().getUser(userId: userId)
                
                // 3. Create post
                let post = Post(
                    caption: caption,
                    imageURL: imageUrl,
                    likeCount: 0,
                    postedUserName: user.name ?? "Unknown",
                    postedUserId: userId,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                try await PostService().createPost(post)
                
                // Reset form
                caption = ""
                selectedImage = nil
                selectedUIImage = nil
                
                alertMessage = "Post created successfully!"
                showAlert = true
                
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
            
            isLoading = false
        }
    }
    
    private func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference().child("post_images/\(filename).jpg")
        
        let _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
}

class HomeViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var lastDocument: DocumentSnapshot?
    
    func fetchPosts() async {
        do {
            let result = try await PostService().getAllPosts(lastDocument: lastDocument)
            DispatchQueue.main.async {
                self.posts.append(contentsOf: result.posts)
                self.lastDocument = result.lastDocument
            }
        } catch {
            print("Error fetching posts: \(error)")
        }
    }
}

#Preview {
    NavigationView {
        HomeContentView()
    }
}

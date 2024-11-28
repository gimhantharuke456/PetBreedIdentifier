import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
   
    @State private var showEditAlert = false
    @State private var showDeleteAlert = false
    @State private var selectedPostIdForEdit: String? = nil
    @State private var editedCaption: String = ""
    @State private var selectedPostForDelete: Post?

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.posts.isEmpty {
                    ContentUnavailableView("No Posts",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Start following people to see their posts"))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.posts) { post in
                                PostCard(post: post,
                                         isLiked: viewModel.likedPosts.contains(post.id ?? ""),
                                         onLike: { handleLike(post) },
                                         onEdit: { startEditing(post) },
                                         onDelete: { confirmDelete(post) })
                            }
                            
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .onAppear {
                                        Task {
                                            await viewModel.loadMorePosts()
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refreshPosts()
                    }
                }
            }
            .navigationTitle("Feed")
            .sheet(isPresented: $showEditAlert) {
                VStack(spacing: 16) {
                    Text("Edit Caption")
                        .font(.headline)
                    
                    TextEditor(text: $editedCaption)
                        .frame(height: 150) // Adjust the height as needed
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    HStack {
                        Button("Cancel") {
                            showEditAlert = false
                        }
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                        Spacer()
                        
                        Button("Save") {
                            saveEditedCaption()
                            showEditAlert = false
                        }
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                    .padding()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding()
            }

            .alert("Delete Post", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    guard let post = selectedPostForDelete else { return }
                    Task {
                        await viewModel.deletePost(post)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this post?")
            }
        }
        .task {
            await viewModel.fetchPosts()
        }
    }
    
    private func handleLike(_ post: Post) {
        Task {
            await viewModel.toggleLike(post)
        }
    }
    
    private func startEditing(_ post: Post) {
        selectedPostIdForEdit = post.id
        editedCaption = post.caption
        showEditAlert = true
    }
    
    private func saveEditedCaption() {
        guard let postId = selectedPostIdForEdit else { return }
        Task {
            if let post = viewModel.posts.first(where: { $0.id == postId }) {
                await viewModel.updatePost(post, newCaption: editedCaption)
            }
        }
        selectedPostIdForEdit = nil
    }
    
    private func confirmDelete(_ post: Post) {
        selectedPostForDelete = post
        showDeleteAlert = true
    }
}

struct PostCard: View {
    let post: Post
    let isLiked: Bool
    let onLike: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showOptions = false
    @State private var animateHeart = false
    @State private var lastTapTime: Date = .now
    
    private var isCurrentUserPost: Bool {
        post.postedUserId == Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // User Info Header
            HStack {
                Text(post.postedUserName)
                    .font(.headline)
                Spacer()
                if isCurrentUserPost {
                    Button {
                        showOptions = true
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .confirmationDialog("Post Options", isPresented: $showOptions) {
                        Button("Edit") { onEdit() }
                        Button("Delete", role: .destructive) { onDelete() }
                    }
                }
            }
            
            // Image
            AsyncImage(url: URL(string: post.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        if animateHeart {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .transition(.scale)
                        }
                    }
                    .onTapGesture(count: 2) { handleDoubleTap() }
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
            }
            
            // Like Button and Count
            HStack {
                Button {
                    withAnimation { onLike() }
                } label: {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .primary)
                }
                
                Text("\(post.likeCount) likes")
                    .font(.subheadline)
            }
            
            // Caption
            Text(post.caption)
                .font(.body)
            
           
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func handleDoubleTap() {
        let now = Date()
        if now.timeIntervalSince(lastTapTime) <= 0.3 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                animateHeart = true
            }
            
            if !isLiked {
                onLike()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    animateHeart = false
                }
            }
        }
        lastTapTime = now
    }
}

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var likedPosts: Set<String> = []
    
    private var lastDocument: DocumentSnapshot?
    private let postService = PostService()
    
    func fetchPosts() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let result = try await postService.getAllPosts()
            await updatePosts(result.posts)
            lastDocument = result.lastDocument
            await fetchLikedStatus()
        } catch {
            print("Error fetching posts: \(error)")
        }
        
        isLoading = false
    }
    
    func loadMorePosts() async {
        guard !isLoadingMore, let lastDocument = lastDocument else { return }
        isLoadingMore = true
        
        do {
            let result = try await postService.getAllPosts(lastDocument: lastDocument)
            await updatePosts(self.posts + result.posts)
            self.lastDocument = result.lastDocument
            await fetchLikedStatus()
        } catch {
            print("Error loading more posts: \(error)")
        }
        
        isLoadingMore = false
    }
    
    func refreshPosts() async {
        lastDocument = nil
        await fetchPosts()
    }
    
    func toggleLike(_ post: Post) async {
        guard let postId = post.id,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            if likedPosts.contains(postId) {
                try await postService.unlikePost(postId: postId, userId: userId)
                await removeLike(postId)
            } else {
                try await postService.likePost(postId: postId, userId: userId)
                await addLike(postId)
            }
            await refreshPost(postId)
        } catch {
        } catch {
            print("Error toggling like: \(error)")
        }
    }
    
    func updatePost(_ post: Post, newCaption: String) async {
        guard var updatedPost = post.id.map({ Post(
            id: $0,
            caption: newCaption,
            imageURL: post.imageURL,
            likeCount: post.likeCount,
            postedUserName: post.postedUserName,
            postedUserId: post.postedUserId,
            createdAt: post.createdAt,
            updatedAt: Date()
        ) }) else { return }
        
        do {
            try await postService.updatePost(updatedPost)
            await updatePostInList(updatedPost)
        } catch {
            print("Error updating post: \(error)")
        }
    }
    
    func deletePost(_ post: Post) async {
        guard let postId = post.id else { return }
        
        do {
            try await postService.deletePost(postId: postId)
            await removePostFromList(postId)
        } catch {
            print("Error deleting post: \(error)")
        }
    }
    
    @MainActor
    private func updatePosts(_ newPosts: [Post]) {
        posts = newPosts
    }
    
    @MainActor
    private func addLike(_ postId: String) {
        likedPosts.insert(postId)
    }
    
    @MainActor
    private func removeLike(_ postId: String) {
        likedPosts.remove(postId)
    }
    
    @MainActor
    private func updatePostInList(_ updatedPost: Post) {
        if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
            posts[index] = updatedPost
        }
    }
    
    @MainActor
    private func removePostFromList(_ postId: String) {
        posts.removeAll { $0.id == postId }
    }
    
    private func refreshPost(_ postId: String) async {
        do {
            let updatedPost = try await postService.getPost(postId: postId)
            await updatePostInList(updatedPost)
        } catch {
            print("Error refreshing post: \(error)")
        }
    }
    
    @MainActor
    private func fetchLikedStatus() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        await withTaskGroup(of: (String, Bool).self) { group in
            for post in posts {
                if let postId = post.id {
                    group.addTask {
                        do {
                            let isLiked = try await self.postService.isPostLikedByUser(postId: postId, userId: userId)
                            return (postId, isLiked)
                        } catch {
                            return (postId, false)
                        }
                    }
                }
            }
            
            likedPosts.removeAll()
            for await (postId, isLiked) in group where isLiked {
                likedPosts.insert(postId)
            }
        }
    }
}



#Preview {
    FeedView()
}

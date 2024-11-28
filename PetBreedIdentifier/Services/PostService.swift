import Foundation
import FirebaseFirestore

class PostService {
    private let db = Firestore.firestore()
    private let postsCollection = "posts"
    private let likesCollection = "likes"
    
    // Create a new post
    func createPost(_ post: Post) async throws {
        let documentRef = db.collection(postsCollection).document()
        var newPost = post
        newPost.id = documentRef.documentID
        try documentRef.setData(from: newPost)
    }
    
    // Get a single post
    func getPost(postId: String) async throws -> Post {
        let snapshot = try await db.collection(postsCollection).document(postId).getDocument()
        guard let post = try? snapshot.data(as: Post.self) else {
            throw NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Post not found"])
        }
        return post
    }
    
    // Get all posts with pagination
    func getAllPosts(limit: Int = 20, lastDocument: DocumentSnapshot? = nil) async throws -> (posts: [Post], lastDocument: DocumentSnapshot?) {
        var query = db.collection(postsCollection)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        let snapshot = try await query.getDocuments()
        let posts = try snapshot.documents.map { document in
                let data = document.data()
                
                // Parse each required field with error handling
                guard
                    let caption = data["caption"] as? String,
                    let imageURL = data["imageURL"] as? String,
                    let likeCount = data["likeCount"] as? Int,
                    let postedUserName = data["postedUserName"] as? String,
                    let postedUserId = data["postedUserId"] as? String,
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue(),
                    let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                else {
                    // If any required field is missing, throw an error
                    throw NSError(domain: "PostServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid post data for document \(document.documentID)"])
                }
                
                // Create the Post instance
                let post = Post(
                    id: document.documentID,
                    caption: caption,
                    imageURL: imageURL,
                    likeCount: likeCount,
                    postedUserName: postedUserName,
                    postedUserId: postedUserId,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
                
                print("Fetched Post - ID: \(post.id ?? "NIL"), Caption: \(post.caption)")
                return post
            }
        let lastDoc = snapshot.documents.last
        
        return (posts, lastDoc)
    }
    
    // Update post
    func updatePost(_ post: Post) async throws {
        guard let postId = post.id else { return }
        try await db.collection(postsCollection).document(postId).setData(from: post, merge: true)
    }
    
    // Delete post
    func deletePost(postId: String) async throws {
        // Delete the post document
        try await db.collection(postsCollection).document(postId).delete()
        
        // Delete all associated likes
        let likesSnapshot = try await db.collection(postsCollection)
            .document(postId)
            .collection(likesCollection)
            .getDocuments()
        
        for doc in likesSnapshot.documents {
            try await doc.reference.delete()
        }
    }
    
    // Like a post
    func likePost(postId: String, userId: String) async throws {
        let batch = db.batch()
        
        // Add like document
        let likeRef = db.collection(postsCollection)
            .document(postId)
            .collection(likesCollection)
            .document(userId)
        
        batch.setData(["userId": userId, "timestamp": FieldValue.serverTimestamp()], forDocument: likeRef)
        
        // Increment like count
        let postRef = db.collection(postsCollection).document(postId)
        batch.updateData(["likeCount": FieldValue.increment(Int64(1))], forDocument: postRef)
        
        try await batch.commit()
    }
    
    // Unlike a post
    func unlikePost(postId: String, userId: String) async throws {
        let batch = db.batch()
        
        // Remove like document
        let likeRef = db.collection(postsCollection)
            .document(postId)
            .collection(likesCollection)
            .document(userId)
        
        batch.deleteDocument(likeRef)
        
        // Decrement like count
        let postRef = db.collection(postsCollection).document(postId)
        batch.updateData(["likeCount": FieldValue.increment(Int64(-1))], forDocument: postRef)
        
        try await batch.commit()
    }
    
    // Check if user liked post
    func isPostLikedByUser(postId: String, userId: String) async throws -> Bool {
        let likeDoc = try await db.collection(postsCollection)
            .document(postId)
            .collection(likesCollection)
            .document(userId)
            .getDocument()
        
        return likeDoc.exists
    }
    
    // Get posts by user
    func getPostsByUser(userId: String) async throws -> [Post] {
        let snapshot = try await db.collection(postsCollection)
            .whereField("postedUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Post.self) }
    }
    
    // Get liked posts by user
    func getLikedPostsByUser(userId: String) async throws -> [Post] {
        var posts: [Post] = []
        
        let snapshot = try await db.collectionGroup(likesCollection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        for doc in snapshot.documents {
            let postId = doc.reference.parent.parent?.documentID
            if let postId = postId {
                if let post = try? await getPost(postId: postId) {
                    posts.append(post)
                }
            }
        }
        
        return posts
    }
    
    func updatePostCaption(postId: String, newCaption: String) async throws {
           let db = Firestore.firestore()
           let postRef = db.collection("posts").document(postId)
           
           try await postRef.updateData([
               "caption": newCaption,
               "updatedAt": FieldValue.serverTimestamp()
           ])
       }
}

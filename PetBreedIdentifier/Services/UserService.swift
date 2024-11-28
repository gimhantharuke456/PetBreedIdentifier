import Foundation
import FirebaseFirestore

class UserService {
    private let db = Firestore.firestore()
    private let usersCollection = "dog_users"
    
    func createUser(_ user: AppUser) async throws {
        guard let userId = user.id else { return }
        try await db.collection(usersCollection).document(userId).setData(from: user)
    }
    
    func getUser(userId: String) async throws -> AppUser {
        let snapshot = try await db.collection(usersCollection).document(userId).getDocument()
        guard let user = try? snapshot.data(as: AppUser.self) else {
            throw NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return user
    }
    
    func updateUser(_ user: AppUser) async throws {
        guard let userId = user.id else { return }
        try await db.collection(usersCollection).document(userId).setData(from: user, merge: true)
    }
    
    func deleteUser(userId: String) async throws {
        try await db.collection(usersCollection).document(userId).delete()
    }
    
    func getAllUsers() async throws -> [AppUser] {
        let snapshot = try await db.collection(usersCollection).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: AppUser.self)
        }
    }
}

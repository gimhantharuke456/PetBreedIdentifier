import Foundation
import FirebaseAuth

enum AuthError: Error {
    case signInError
    case signOutError
    case signUpError
}

class AuthenticationService {
    static let shared = AuthenticationService()
    private init() {}
    
    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    func signUp(email: String, password: String) async throws -> FirebaseAuth.User {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return authResult.user
        } catch {
            throw AuthError.signUpError
        }
    }
    
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            return authResult.user
        } catch {
            throw AuthError.signInError
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw AuthError.signOutError
        }
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}

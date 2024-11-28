import XCTest
@testable import PetBreedIdentifier
import FirebaseAuth

final class AuthenticationServiceTests: XCTestCase {
    var authService: AuthenticationService!

    override func setUp() {
        super.setUp()
        authService = AuthenticationService.shared
    }

    override func tearDown() {
        authService = nil
        super.tearDown()
    }

    func testSignInWithValidCredentials() async throws {
        // Mock Firebase Auth
        let email = "test@example.com"
        let password = "password123"
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            XCTAssertNotNil(user, "User should not be nil")
        } catch {
            XCTFail("Sign-in failed with valid credentials: \(error.localizedDescription)")
        }
    }

    func testSignInWithInvalidCredentials() async throws {
        let email = "invalid@example.com"
        let password = "wrongpassword"
        
        do {
            _ = try await authService.signIn(email: email, password: password)
            XCTFail("Sign-in should fail with invalid credentials")
        } catch {
            XCTAssertEqual(error as? AuthError, AuthError.signInError, "Expected sign-in error")
        }
    }

    func testSignOut() {
        do {
            try authService.signOut()
            XCTAssertNil(authService.currentUser, "Current user should be nil after sign-out")
        } catch {
            XCTFail("Sign-out failed: \(error.localizedDescription)")
        }
    }
}

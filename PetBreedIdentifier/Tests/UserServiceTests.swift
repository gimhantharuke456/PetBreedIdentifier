import XCTest
@testable import PetBreedIdentifier
import FirebaseFirestore

final class UserServiceTests: XCTestCase {
    var userService: UserService!
    let testUserId = "testUser123"
    
    override func setUp() {
        super.setUp()
        userService = UserService()
    }

    override func tearDown() {
        userService = nil
        super.tearDown()
    }

    func testCreateAndFetchUser() async throws {
        let user = AppUser(
            id: testUserId,
            name: "Test User",
            email: "testuser@example.com",
            petName: "Buddy",
            petImageURL: "https://example.com/image.jpg",
            createdAt: Date(),
            updatedAt: Date()
        )

        do {
            try await userService.createUser(user)
            let fetchedUser = try await userService.getUser(userId: testUserId)
            XCTAssertEqual(fetchedUser.id, testUserId, "Fetched user ID should match created user ID")
        } catch {
            XCTFail("Failed to create or fetch user: \(error.localizedDescription)")
        }
    }
}

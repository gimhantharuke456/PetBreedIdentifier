import XCTest

final class LoginViewUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testLoginSuccess() throws {
        // Input email and password
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]

        emailField.tap()
        emailField.typeText("test@example.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Check if navigation to HomeView occurred
        XCTAssertTrue(app.staticTexts["Welcome Home"].exists, "HomeView should be displayed on successful login")
    }

    func testLoginFailure() throws {
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]

        emailField.tap()
        emailField.typeText("invalid@example.com")

        passwordField.tap()
        passwordField.typeText("wrongpassword")

        loginButton.tap()

        // Verify error alert is displayed
        XCTAssertTrue(app.alerts["Error"].exists, "Error alert should be displayed on login failure")
    }
}

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var currentUser: User?

    var body: some View {
        Group {
            if let _ = currentUser {
                HomeView()
            } else {
                SplashView()
            }
        }
        .onAppear {
            setupAuthListener()
        }
    }

    func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.currentUser = user
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

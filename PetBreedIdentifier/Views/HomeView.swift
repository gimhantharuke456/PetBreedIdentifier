import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Home Tab
                FeedView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                HomeContentView()
                    .tabItem {
                        Image(systemName: "plus")
                        Text("Post")
                    }
                    .tag(1)
                
                // Identifier Tab
                IdentifierView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Identifier")
                    }
                    .tag(2)
                
                // Profile Tab
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(3)
            }
            .accentColor(.orange) // Matches your theme color
        }
    }
}


#Preview {
    HomeView()
}

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            StoreView()
                .tabItem {
                    Label("Store", systemImage: "cart")
                }
                .tag(1)
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
        .accentColor(.red)
    }
}

#Preview {
    MainTabView()
} 
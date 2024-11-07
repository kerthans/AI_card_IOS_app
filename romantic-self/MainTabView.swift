import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首页")
                }
            
            TreeHoleView()
                .tabItem {
                    Image(systemName: "bubble.left.fill")
                    Text("树洞")
                }
            
            UniverseView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("小宇宙")
                }
//            
//            ProfileView()
//                .tabItem {
//                    Image(systemName: "heart.fill")
//                    Text("小窝")
//                }
        }
        .accentColor(.mintBlue)
    }
}


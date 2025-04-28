import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NewsView().tabItem {
                Label("ニュース", systemImage: "newspaper")
            }

            PromptMarketView().tabItem {
                Label("プロンプト", systemImage: "lightbulb")
            }

            BoardView()
                .environmentObject(BoardViewModel())
                .tabItem {
                    Label("掲示板", systemImage: "bubble.left.and.bubble.right")
                }

            MyPageView().tabItem {
                Label("マイページ", systemImage: "person.crop.circle")
            }
        }
    }
}

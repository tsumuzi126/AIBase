import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var subManager: SubscriptionManager

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: SavedPromptsView()) {
                        Label("保存したプロンプト", systemImage: "bookmark.fill")
                    }

                    NavigationLink(destination: PremiumStatusView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("プレミアム会員ステータス")
                                Text(subManager.isPremiumUser ? "ご利用中のプラン：プレミアム" : "ご利用中のプラン：無料")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        } icon: {
                            Image(systemName: "crown.fill")
                        }
                    }

                    Label("ログアウトする", systemImage: "rectangle.portrait.and.arrow.forward")
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("マイページ")
        }
    }
}

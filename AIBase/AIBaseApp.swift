import GoogleMobileAds
import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct AIBaseApp: App {
    @StateObject private var subManager = SubscriptionManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var savedManager = SavedPromptManager()
    @StateObject private var favoriteManager = FavoriteManager()
    @State private var showNicknamePrompt = false
    
    init() {
        FirebaseApp.configure()
        
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("匿名ログイン失敗: \(error.localizedDescription)")
                } else {
                    print("匿名ログイン成功: \(result?.user.uid ?? "不明")")
                }
            }
        }
        
        _ = AdMobManager.shared // ← ここで明示的に初期化
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subManager)
                .environmentObject(userManager)
                .environmentObject(savedManager)
                .environmentObject(favoriteManager)
                .onAppear {
                    userManager.fetchOrCreateUser()
                }
                .onReceive(NotificationCenter.default.publisher(for: .shouldPromptForNickname)) { _ in
                    showNicknamePrompt = true
                }
                .sheet(isPresented: $showNicknamePrompt) {
                    NicknamePromptView()
                        .environmentObject(userManager)
                }
        }
    }
}

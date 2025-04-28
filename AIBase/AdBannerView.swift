import SwiftUI
import GoogleMobileAds

// AdMob初期化クラス
final class AdMobManager {
    static let shared = AdMobManager()
    init() {
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "1b87d8c8224efac914a4cfb3bfa3a1db"
        ]
        MobileAds.shared.start(completionHandler: { _ in })
    }
}

// SwiftUI用のバナー表示View
struct AdBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let view = BannerView(adSize: AdSizeBanner)
        view.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Google公式テストID
        view.rootViewController = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
        view.load(Request())
        return view
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

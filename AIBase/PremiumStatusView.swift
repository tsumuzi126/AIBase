import SwiftUI
import StoreKit

struct PremiumStatusView: View {
    @EnvironmentObject var subManager: SubscriptionManager

    var body: some View {
        VStack(spacing: 24) {
            Text(subManager.isPremiumUser ? "✅ あなたはプレミアム会員です" : "🚫 プレミアム未加入")
                .font(.headline)

            if !subManager.isPremiumUser {
                Button(action: {
                    Task {
                        await subManager.purchasePremium()
                    }
                }) {
                    Text("¥980/月でプレミアムに加入する")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("特典内容")
                    .font(.headline)
                Text("・広告がすべて非表示になります\n・今後の有料機能がアンロックされます")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("購入を復元する") {
                Task {
                    do {
                        if let result = try await StoreKit.Transaction.latest(for: subManager.premiumProductID),
                           case .verified(let transaction) = result,
                           transaction.revocationDate == nil {
                            subManager.isPremiumUser = true
                        } else {
                            subManager.isPremiumUser = false
                        }
                    } catch {
                        print("🔁 購入復元失敗: \(error)")
                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(.top, 12)

            Spacer()
        }
        .padding()
        .navigationTitle("プレミアムプラン")
    }
}

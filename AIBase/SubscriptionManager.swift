import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isPremiumUser: Bool = false
    @Published var isChecking: Bool = true
    let premiumProductID = "aibase_premium_monthly"

    init() {
        Task {
            await checkSubscriptionStatus()
        }
    }

    func checkSubscriptionStatus() async {
        isChecking = true
        defer { isChecking = false }

        do {
            if let result = try await Transaction.latest(for: premiumProductID),
               case .verified(let transaction) = result,
               transaction.revocationDate == nil,
               !transaction.isUpgraded {
                isPremiumUser = true
            } else {
                isPremiumUser = false
            }
        } catch {
            print("🔴 サブスク状態の確認に失敗: \(error)")
            isPremiumUser = false
        }
    }

    func purchasePremium() async {
        do {
            guard let product = try await Product.products(for: [premiumProductID]).first else { return }
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isPremiumUser = true
                }
            default:
                break
            }
        } catch {
            print("🔴 購入失敗: \(error)")
        }
    }
}

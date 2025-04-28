import Foundation

struct PromptItem: Identifiable {
    var id: String
    var title: String
    var description: String
    var isFree: Bool
    var price: Int
    var createdAt: Date
    var content: String
    var featured: Bool          // ★ 追加
    var tags: [String]          // ★ 追加
    var userDisplayName: String
}

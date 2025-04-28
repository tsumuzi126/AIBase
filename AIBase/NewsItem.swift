import Foundation

struct ArchivedNewsItem: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var imageUrl: String?
    var link: String?
    var publishedAt: Date
}

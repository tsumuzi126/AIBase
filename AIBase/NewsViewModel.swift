import Foundation
import FirebaseFirestore

class NewsViewModel: ObservableObject {
    // MARK: - Published State
    @Published var news: [ArchivedNewsItem] = []
    @Published var showArchive = false
    @Published var hasMore = true

    // MARK: - Private
    private let db = Firestore.firestore()
    private var lastDoc: DocumentSnapshot?
    private let pageSize = 10
    private var isLoading = false

    // MARK: - Lifecycle
    init() {
        fetchInitial()
    }

    // MARK: - Public API

    /// 最初の1ページ分を取得
    func fetchInitial() {
        guard !isLoading else { return }
        isLoading = true

        db.collection("news")
            .order(by: "publishedAt", descending: true)
            .limit(to: pageSize)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false

                let docs = snapshot?.documents ?? []
                self.lastDoc = docs.last
                self.hasMore = docs.count == self.pageSize
                self.news = docs.compactMap(Self.map)
            }
    }

    /// 「もっと見る」などで追加取得
    func fetchMore() {
        guard hasMore, !isLoading, let lastDoc else { return }
        isLoading = true

        db.collection("news")
            .order(by: "publishedAt", descending: true)
            .start(afterDocument: lastDoc)
            .limit(to: pageSize)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false

                let docs = snapshot?.documents ?? []
                if docs.isEmpty {
                    self.hasMore = false
                    return
                }

                self.lastDoc = docs.last
                self.hasMore = docs.count == self.pageSize
                self.news.append(contentsOf: docs.compactMap(Self.map))
            }
    }

    // MARK: - Mapping helper

    private static func map(_ doc: QueryDocumentSnapshot) -> ArchivedNewsItem? {
        let d = doc.data()
        guard
            let title = d["title"] as? String,
            let description = d["description"] as? String,
            let ts = d["publishedAt"] as? Timestamp
        else { return nil }

        return ArchivedNewsItem(
            id: doc.documentID,
            title: title,
            description: description,
            imageUrl: d["imageUrl"] as? String,
            link: d["link"] as? String,
            publishedAt: ts.dateValue()
        )
    }
}

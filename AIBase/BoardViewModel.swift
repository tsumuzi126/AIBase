import Foundation
import FirebaseFirestore

struct ForumThread: Identifiable {
    var id: String
    var title: String
    var createdAt: Date
}

@MainActor
class BoardViewModel: ObservableObject {
    @Published var threads: [ForumThread] = []
    @Published var newThreadTitle: String = ""
    @Published var isPresentingNewThreadSheet: Bool = false
    @Published var commentCounts: [String: Int] = [:]

    private let db = Firestore.firestore()

    init() {
        fetchThreads()
    }

    func fetchThreads() {
        db.collection("threads")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.threads = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let title = data["title"] as? String,
                        let timestamp = data["createdAt"] as? Timestamp
                    else { return nil }

                    return ForumThread(id: doc.documentID, title: title, createdAt: timestamp.dateValue())
                }
                for thread in self?.threads ?? [] {
                    self?.fetchCommentCount(for: thread.id)
                }
            }
    }

    private func fetchCommentCount(for threadId: String) {
        db.collection("threads").document(threadId).collection("comments")
            .getDocuments { [weak self] snapshot, _ in
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.commentCounts[threadId] = count
                }
            }
    }

    func addThread() async {
        let newData: [String: Any] = [
            "title": newThreadTitle,
            "createdAt": Timestamp(date: Date())
        ]
        do {
            _ = try await db.collection("threads").addDocument(data: newData)
            newThreadTitle = ""
            isPresentingNewThreadSheet = false
        } catch {
            print("🔥 Failed to add thread: \(error)")
        }
    }
}

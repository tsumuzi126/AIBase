import Foundation
import FirebaseFirestore
import FirebaseAuth

struct CommentItem: Identifiable {
    let id: String
    let text: String
    let createdAt: Date
    let uid: String
}

class ThreadDetailViewModel: ObservableObject {
    @Published var comments: [CommentItem] = []
    private let db = Firestore.firestore()

    func fetchComments(threadId: String) {
        db.collection("threads").document(threadId).collection("comments")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("コメント取得エラー: \(error)")
                    return
                }
                self?.comments = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    guard let text = data["text"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp,
                          let uid = data["uid"] as? String else {
                        return nil
                    }
                    return CommentItem(
                        id: doc.documentID,
                        text: text,
                        createdAt: timestamp.dateValue(),
                        uid: uid
                    )
                } ?? []
            }
    }

    func postComment(threadId: String, text: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let newComment: [String: Any] = [
            "text": text,
            "createdAt": FieldValue.serverTimestamp(),
            "uid": uid
        ]

        db.collection("threads").document(threadId).collection("comments")
            .addDocument(data: newComment) { error in
                if let error = error {
                    print("コメント投稿エラー: \(error)")
                } else {
                    self.fetchComments(threadId: threadId)
                }
            }
    }
}

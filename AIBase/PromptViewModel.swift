import Foundation
import FirebaseFirestore

class PromptViewModel: ObservableObject {
    @Published var prompts: [PromptItem] = []
    @Published var featuredFree: [PromptItem] = []
    @Published var allTags: [String] = []
    @Published var selectedTag: String? = nil

    private let db = Firestore.firestore()

    func fetchPrompts() {
        db.collection("prompts")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                self.prompts = snapshot?.documents.compactMap { doc in
                    let d = doc.data()
                    guard
                        let title = d["title"] as? String,
                        let description = d["description"] as? String,
                        let isFree = d["isFree"] as? Bool,
                        let price = d["price"] as? Int,
                        let ts = d["createdAt"] as? Timestamp,
                        let content = d["content"] as? String
                    else { return nil }

                    let featured = d["featured"] as? Bool ?? false
                    let tags = d["tags"] as? [String] ?? []

                    return PromptItem(
                        id: doc.documentID,
                        title: title,
                        description: description,
                        isFree: isFree,
                        price: price,
                        createdAt: ts.dateValue(),
                        content: content,
                        featured: featured,
                        tags: tags,
                        userDisplayName: d["userDisplayName"] as? String ?? "匿名"
                    )
                } ?? []

                self.allTags = Array(Set(self.prompts.flatMap { $0.tags })).sorted()
                self.featuredFree = self.prompts.filter { $0.featured && $0.isFree }
            }
    }
    
    func observePrompts() {
        db.collection("prompts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                guard let documents = snapshot?.documents else { return }

                self.prompts = documents.compactMap { doc in
                    let d = doc.data()
                    guard
                        let title = d["title"] as? String,
                        let description = d["description"] as? String,
                        let isFree = d["isFree"] as? Bool,
                        let price = d["price"] as? Int,
                        let ts = d["createdAt"] as? Timestamp,
                        let content = d["content"] as? String
                    else { return nil }

                    let featured = d["featured"] as? Bool ?? false
                    let tags = d["tags"] as? [String] ?? []

                    return PromptItem(
                        id: doc.documentID,
                        title: title,
                        description: description,
                        isFree: isFree,
                        price: price,
                        createdAt: ts.dateValue(),
                        content: content,
                        featured: featured,
                        tags: tags,
                        userDisplayName: d["userDisplayName"] as? String ?? "匿名"
                    )
                }

                self.allTags = Array(Set(self.prompts.flatMap { $0.tags })).sorted()
                self.featuredFree = self.prompts.filter { $0.featured && $0.isFree }
            }
    }
}

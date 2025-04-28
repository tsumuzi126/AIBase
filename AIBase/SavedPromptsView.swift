import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SavedPromptsView: View {
    @EnvironmentObject var savedManager: SavedPromptManager
    @State private var prompts: [PromptItem] = []

    var body: some View {
        NavigationStack {
            List(prompts) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("保存済みプロンプト")
            .onAppear {
                Task {
                    await loadSavedPrompts()
                }
            }
        }
    }

    private func loadSavedPrompts() async {
        let db = Firestore.firestore()
        var result: [PromptItem] = []

        for id in savedManager.savedPromptIds {
            do {
                let doc = try await db.collection("prompts").document(id).getDocument()
                guard let data = doc.data(),
                      let title = data["title"] as? String,
                      let description = data["description"] as? String,
                      let content = data["content"] as? String,
                      let isFree = data["isFree"] as? Bool,
                      let price = data["price"] as? Int,
                      let ts = data["createdAt"] as? Timestamp
                else { continue }

                let item = PromptItem(
                    id: doc.documentID,
                    title: title,
                    description: description,
                    isFree: isFree,
                    price: price,
                    createdAt: ts.dateValue(),
                    content: content,
                    featured: data["featured"] as? Bool ?? false,
                    tags: data["tags"] as? [String] ?? [],
                    userDisplayName: data["userDisplayName"] as? String ?? "匿名"
                )
                result.append(item)
            } catch {
                print("保存済みプロンプト取得失敗: \(error)")
            }
        }

        DispatchQueue.main.async {
            self.prompts = result
        }
    }
}

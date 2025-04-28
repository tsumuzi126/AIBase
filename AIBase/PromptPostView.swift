import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PromptPostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @State private var title = ""
    @State private var description = ""
    @State private var content = ""
    @State private var tags = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("タイトル")) {
                    TextField("例：営業メール作成用", text: $title)
                }

                Section(header: Text("説明（任意）")) {
                    TextField("どんな用途かなど", text: $description)
                }

                Section(header: Text("プロンプト内容")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                }

                Section(header: Text("タグ（カンマ区切り）")) {
                    TextField("例：営業,メール,ChatGPT", text: $tags)
                }

                Section {
                    Button(action: {
                        Task { await savePrompt() }
                    }) {
                        Text("投稿する")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(title.isEmpty || content.isEmpty || isSaving)
                }
            }
            .navigationTitle("プロンプト投稿")
        }
    }

    private func savePrompt() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isSaving = true
        let db = Firestore.firestore()

        let data: [String: Any] = [
            "title": title,
            "description": description,
            "content": content,
            "tags": tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "createdAt": FieldValue.serverTimestamp(),
            "userId": uid,
            "userDisplayName": userManager.displayName,
            "isFree": true,
            "price": 0,
            "featured": false
        ]

        do {
            try await db.collection("prompts").addDocument(data: data)
            dismiss()
        } catch {
            print("🔥 投稿失敗: \(error)")
        }
        isSaving = false
    }
}

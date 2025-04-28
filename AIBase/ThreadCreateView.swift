import SwiftUI

struct ThreadCreateView: View {
    @Binding var title: String
    var onSubmit: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("スレッドタイトル")) {
                    TextField("タイトルを入力", text: $title)
                }
            }
            .navigationTitle("新規スレッド")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("作成") {
                        onSubmit()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        title = ""
                    }
                }
            }
        }
    }
}

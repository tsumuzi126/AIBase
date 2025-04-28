import SwiftUI

struct NicknamePromptView: View {
    @State private var nickname: String = ""
    @State private var showError: Bool = false
    private let maxNicknameLength = 20
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("ニックネーム")) {
                    TextField("例：そーた", text: $nickname)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onChange(of: nickname) { newValue in
                            if newValue.count > maxNicknameLength {
                                nickname = String(newValue.prefix(maxNicknameLength))
                            }
                        }
                    if showError {
                        Text("ニックネームを入力してください。")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button(action: {
                        if nickname.trimmingCharacters(in: .whitespaces).isEmpty {
                            showError = true
                        } else {
                            showError = false
                            userManager.saveDisplayName(nickname)
                            dismiss()
                        }
                    }) {
                        Text("登録する")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("ユーザー登録")
        }
    }
}

import SwiftUI

struct PromptDetailView: View {
    let item: PromptItem
    @State private var showCopiedToast = false
    @EnvironmentObject var favoriteManager: FavoriteManager
    @State private var isFavorite: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // タイトル & 説明
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.title2)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.description)
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("投稿者：\(item.userDisplayName)")
                        .font(.body)
                        .foregroundColor(.gray)
                }

                // プロンプト内容見出し & コンテンツ
                VStack(alignment: .leading, spacing: 4) {
                    Text("プロンプト内容")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextEditor(text: .constant(item.content))
                        .font(.body)
                        .disabled(true)
                        .frame(minHeight: 200, maxHeight: 300)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // コピーするボタンとトースト
                VStack(spacing: 8) {
                    Button(action: {
                        UIPasteboard.general.string = item.content
                        showCopiedToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showCopiedToast = false
                        }
                    }) {
                        Text("このプロンプトをコピー")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 20))

                    if showCopiedToast {
                        Text("コピーしました")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: Capsule())
                            .transition(.opacity)
                    }
                }

                Spacer()
            }
            .padding(16)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("プロンプト詳細")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFavorite = favoriteManager.isFavorite(promptId: item.id)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isFavorite.toggle()
                    if isFavorite {
                        favoriteManager.addFavorite(promptId: item.id)
                    } else {
                        favoriteManager.removeFavorite(promptId: item.id)
                    }
                }) {
                    Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isFavorite ? .blue : .primary)
                }
            }
        }
    }
}

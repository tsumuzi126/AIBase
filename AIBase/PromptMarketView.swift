import SwiftUI

struct PromptMarketView: View {
    @StateObject private var viewModel = PromptViewModel()
    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var savedManager: SavedPromptManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    TextField("キーワード検索", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    // タグ選択UI（横スクロール）
                    if !viewModel.allTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.allTags, id: \.self) { tag in
                                    Button(action: {
                                        selectedTag = (selectedTag == tag) ? nil : tag
                                    }) {
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                selectedTag == tag ? Color.blue : Color.gray.opacity(0.2)
                                            )
                                            .foregroundColor(selectedTag == tag ? .white : .primary)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }

                    LazyVStack(spacing: 12) {
                        ForEach(filteredPrompts) { item in
                            ZStack(alignment: .topTrailing) {
                                NavigationLink(destination: PromptDetailView(item: item)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(item.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(item.description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    )
                                }
                                .buttonStyle(.plain)

                                Button(action: {
                                    if savedManager.isSaved(promptId: item.id) {
                                        savedManager.unsavePrompt(promptId: item.id)
                                    } else {
                                        savedManager.savePrompt(promptId: item.id)
                                    }
                                }) {
                                    Image(systemName: savedManager.isSaved(promptId: item.id) ? "bookmark.fill" : "bookmark")
                                        .foregroundColor(savedManager.isSaved(promptId: item.id) ? .blue : .gray)
                                        .padding(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 16)
                }
                .navigationTitle("プロンプト")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: PromptPostView()) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .onAppear { viewModel.observePrompts() }

                // 📢 AdMobバナー
                if !subManager.isChecking && !subManager.isPremiumUser {
                    GeometryReader { geometry in
                        AdBannerView()
                            .frame(width: geometry.size.width, height: 50)
                    }
                    .frame(height: 50)
                }
            }
        }
    }

    private var filteredPrompts: [PromptItem] {
        viewModel.prompts.filter { item in
            (selectedTag == nil || item.tags.contains(selectedTag!)) &&
            (searchText.isEmpty || item.title.localizedCaseInsensitiveContains(searchText) || item.description.localizedCaseInsensitiveContains(searchText))
        }
    }
}

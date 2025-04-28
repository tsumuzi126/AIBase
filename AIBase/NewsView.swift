import SwiftUI
import FirebaseFirestore


struct NewsView: View {
    @StateObject private var viewModel = NewsViewModel()
    @EnvironmentObject var subManager: SubscriptionManager // ✅ 追加
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        let filteredItems = viewModel.news.filter { item in
                            searchText.isEmpty ||
                            item.title.localizedCaseInsensitiveContains(searchText) ||
                            item.description.localizedCaseInsensitiveContains(searchText)
                        }

                        ForEach(filteredItems) { item in
                            NavigationLink(destination: NewsDetailView(item: item)) {
                                NewsCardView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                        if viewModel.hasMore {
                            Button {
                                viewModel.fetchMore()
                            } label: {
                                Text("もっと見る")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 1.2)
                                    )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .searchable(text: $searchText, prompt: "キーワード検索")

                if !subManager.isChecking && !subManager.isPremiumUser {
                    GeometryReader { geometry in
                        AdBannerView()
                            .frame(width: geometry.size.width, height: 50)
                    }
                    .frame(height: 50)
                }
            }
            .navigationTitle("AIニュース")
            .onAppear {
                if viewModel.news.isEmpty {
                    viewModel.fetchInitial()
                }
            }
        }
    }
}

struct NewsCardView: View {
    let item: ArchivedNewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let urlString = item.imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                }
            }
            Text(formattedDate(item.publishedAt))
                .font(.caption)
                .foregroundColor(.gray)
            Text(item.title)
                .font(.headline)
                .lineLimit(2)
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.22), radius: 4, x: 0, y: 2)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

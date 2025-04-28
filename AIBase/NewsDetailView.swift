import SwiftUI

struct NewsDetailView: View {
    let item: ArchivedNewsItem
    @State private var showSafari = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let url = URL(string: item.imageUrl ?? "") {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 240)
                            .clipped()
                            .cornerRadius(12)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .frame(height: 240)
                            .cornerRadius(12)
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(item.title)
                        .font(.title2)
                        .bold()
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                        .minimumScaleFactor(1)
                        .padding(.bottom, 16)

                    Text(item.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(1)

                    if let source = item.link, let url = URL(string: source) {
                        Button {
                            showSafari = true
                        } label: {
                            Text("▶︎ 元記事を読む")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 24)
                        .sheet(isPresented: $showSafari) {
                            SafariWebView(url: url)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("ニュース詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

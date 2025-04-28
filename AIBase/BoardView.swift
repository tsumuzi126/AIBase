import SwiftUI

struct BoardView: View {
    @EnvironmentObject var viewModel: BoardViewModel
    @EnvironmentObject var subManager: SubscriptionManager

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List(viewModel.threads) { thread in
                    NavigationLink(destination: ThreadDetailView(thread: thread)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(thread.title)
                                .font(.headline)
                            Text(formattedDate(thread.createdAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                            if let count = viewModel.commentCounts[thread.id] {
                                Text("コメント数: \(count)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("掲示板")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.isPresentingNewThreadSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $viewModel.isPresentingNewThreadSheet) {
                    ThreadCreateView(title: $viewModel.newThreadTitle, onSubmit: {
                        Task {
                            await viewModel.addThread()
                        }
                    })
                }

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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

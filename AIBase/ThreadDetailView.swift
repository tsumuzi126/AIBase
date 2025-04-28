import SwiftUI

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    return formatter
}()

struct ThreadDetailView: View {
    let thread: ForumThread
    @State private var newComment: String = ""
    @StateObject private var viewModel = ThreadDetailViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // 固定ヘッダー
            HStack {
                Text(thread.title)
                    .font(.headline)
                    .bold()
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
            }
            .background(Color(.systemBackground))
            .overlay(
                Divider(),
                alignment: .bottom
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.comments) { comment in
                        HStack(alignment: .bottom, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(comment.text)
                                    .font(.body)
                                    .padding(10)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                                
                                Text(dateFormatter.string(from: comment.createdAt))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }

            Divider()

            HStack(alignment: .center) {
                TextField("コメントを書く", text: $newComment)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .font(.body)

                Button(action: {
                    if !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.postComment(threadId: thread.id, text: newComment)
                        newComment = ""
                    }
                }) {
                    Text("送信")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .onAppear {
            viewModel.fetchComments(threadId: thread.id)
        }
    }
}

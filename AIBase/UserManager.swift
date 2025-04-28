import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserManager: ObservableObject {
    @Published var displayName: String = ""
    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    func fetchOrCreateUser() {
        guard let uid = auth.currentUser?.uid else { return }

        let userRef = db.collection("users").document(uid)

        userRef.getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(), let name = data["displayName"] as? String {
                self?.displayName = name
            } else {
                // まだ登録されていない → ニックネーム登録に進ませる
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .shouldPromptForNickname, object: nil)
                }
            }
        }
    }

    func saveDisplayName(_ name: String) {
        guard let uid = auth.currentUser?.uid else { return }

        db.collection("users").document(uid).setData([
            "displayName": name,
            "createdAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            if error == nil {
                self?.displayName = name
            }
        }
    }
}

extension Notification.Name {
    static let shouldPromptForNickname = Notification.Name("shouldPromptForNickname")
}

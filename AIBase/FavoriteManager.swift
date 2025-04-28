//
//  FavoriteManager.swift
//  AIBase
//
//  Created by s002343 on 2025/04/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

class FavoriteManager: ObservableObject {
    @Published var favoritePromptIds: Set<String> = []
    private let db = Firestore.firestore()
    private var uid: String? {
        Auth.auth().currentUser?.uid
    }

    func loadFavorites() {
        guard let uid else { return }
        db.collection("users").document(uid).collection("favorites")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self?.favoritePromptIds = Set(documents.compactMap { $0.documentID })
                }
            }
    }

    func isFavorite(promptId: String) -> Bool {
        return favoritePromptIds.contains(promptId)
    }

    func addFavorite(promptId: String) {
        guard let uid else { return }
        let docRef = db.collection("users").document(uid).collection("favorites").document(promptId)
        docRef.setData([
            "promptId": promptId,
            "createdAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.favoritePromptIds.insert(promptId)
                }
            }
        }
    }

    func removeFavorite(promptId: String) {
        guard let uid else { return }
        let docRef = db.collection("users").document(uid).collection("favorites").document(promptId)
        docRef.delete { [weak self] error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.favoritePromptIds.remove(promptId)
                }
            }
        }
    }
}

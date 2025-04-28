//
//  SavedPromptManager.swift
//  AIBase
//
//  Created by s002343 on 2025/04/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class SavedPromptManager: ObservableObject {
    @Published var savedPromptIds: Set<String> = []
    private let db = Firestore.firestore()
    private var uid: String? {
        Auth.auth().currentUser?.uid
    }

    func loadSavedPrompts() {
        guard let uid else { return }
        db.collection("users").document(uid).collection("saved")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self?.savedPromptIds = Set(documents.map { $0.documentID })
                }
            }
    }

    func isSaved(promptId: String) -> Bool {
        savedPromptIds.contains(promptId)
    }

    func savePrompt(promptId: String) {
        guard let uid else { return }
        let docRef = db.collection("users").document(uid).collection("saved").document(promptId)
        docRef.setData([
            "promptId": promptId,
            "savedAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.savedPromptIds.insert(promptId)
                }
            }
        }
    }

    func unsavePrompt(promptId: String) {
        guard let uid else { return }
        let docRef = db.collection("users").document(uid).collection("saved").document(promptId)
        docRef.delete { [weak self] error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.savedPromptIds.remove(promptId)
                }
            }
        }
    }
}

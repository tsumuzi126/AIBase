//
//  SafariWebView.swift
//  AIBase
//
//  Created by s002343 on 2025/04/17.
//

import SwiftUI
import SafariServices

/// A lightweight wrapper that opens the given URL in an in‑app Safari view,
/// matching Apple Storeアプリの “記事詳細→Web 表示” 体験.
struct SafariWebView: UIViewControllerRepresentable {
    /// URL to load.
    let url: URL

    // MARK: UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.dismissButtonStyle = .close
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Nothing to update – the URL is fixed on creation.
    }
}

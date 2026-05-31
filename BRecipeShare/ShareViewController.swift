import UIKit
import SwiftUI

final class ShareViewController: UIViewController {

    private let state = ShareState()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let vc = UIHostingController(rootView: ShareView(state: state))
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: view.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        vc.didMove(toParent: self)

        extractSharedContent()
    }

    // MARK: - Content extraction

    private func extractSharedContent() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            complete(); return
        }

        for item in items {
            for provider in item.attachments ?? [] {
                // 1. Prefer a proper URL (Instagram, TikTok, YouTube, Safari all share URLs)
                if provider.hasItemConformingToTypeIdentifier("public.url") {
                    provider.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] data, _ in
                        let urlString: String?
                        if let url = data as? URL { urlString = url.absoluteString }
                        else if let str = data as? String, !str.isEmpty { urlString = str }
                        else { urlString = nil }
                        DispatchQueue.main.async {
                            if let str = urlString {
                                PendingImportStore.save(PendingImport(kind: .url, content: str))
                            }
                            self?.markSavedAndDismiss()
                        }
                    }
                    return
                }
                // 2. Fall back to plain text (copied recipe text, or a URL in text form)
                if provider.hasItemConformingToTypeIdentifier("public.plain-text") {
                    provider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { [weak self] data, _ in
                        DispatchQueue.main.async {
                            if let text = data as? String, !text.isEmpty {
                                let isURL = text.hasPrefix("http://") || text.hasPrefix("https://")
                                PendingImportStore.save(PendingImport(kind: isURL ? .url : .text, content: text))
                            }
                            self?.markSavedAndDismiss()
                        }
                    }
                    return
                }
            }
        }
        complete()
    }

    private func markSavedAndDismiss() {
        state.saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.complete()
        }
    }

    private func complete() {
        extensionContext?.completeRequest(returningItems: [])
    }
}

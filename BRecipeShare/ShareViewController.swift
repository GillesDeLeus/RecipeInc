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

        var foundURL: String? = nil
        var foundText: String? = nil
        var foundImageData: Data? = nil

        // The item-level attributedContentText often carries the post caption
        // (Instagram, TikTok, Threads all populate this when sharing a post)
        for item in items {
            if let caption = item.attributedContentText?.string {
                let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { foundText = trimmed }
            }
        }

        // Use a DispatchGroup to collect all async provider loads
        let group = DispatchGroup()

        for item in items {
            for provider in item.attachments ?? [] {
                // URL attachment
                if provider.hasItemConformingToTypeIdentifier("public.url"), foundURL == nil {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: "public.url", options: nil) { data, _ in
                        // loadItem completions run on arbitrary queues; hop to main
                        // so foundURL/foundText are only ever mutated from one queue.
                        DispatchQueue.main.async {
                            defer { group.leave() }
                            if let url = data as? URL { foundURL = url.absoluteString }
                            else if let str = data as? String, !str.isEmpty { foundURL = str }
                        }
                    }
                }
                // Image attachment (recipe screenshots; OCR'd in the main app)
                if provider.hasItemConformingToTypeIdentifier("public.image"), foundImageData == nil {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: "public.image", options: nil) { data, _ in
                        DispatchQueue.main.async {
                            defer { group.leave() }
                            guard foundImageData == nil else { return }
                            switch data {
                            case let fileURL as URL:
                                foundImageData = try? Data(contentsOf: fileURL)
                            case let image as UIImage:
                                foundImageData = image.jpegData(compressionQuality: 0.9)
                            case let raw as Data:
                                foundImageData = raw
                            default:
                                break
                            }
                        }
                    }
                }
                // Plain text attachment (some apps embed the caption here too)
                if provider.hasItemConformingToTypeIdentifier("public.plain-text"), foundText == nil {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { data, _ in
                        DispatchQueue.main.async {
                            defer { group.leave() }
                            if let str = data as? String {
                                let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                // If it looks like a URL, treat it as one
                                if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
                                    if foundURL == nil { foundURL = trimmed }
                                } else {
                                    foundText = trimmed
                                }
                            }
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if let url = foundURL {
                // Social media URL + caption text → send the text so AI can parse the recipe
                if let text = foundText, !text.isEmpty, self.isSocialMedia(urlString: url) {
                    PendingImportStore.save(PendingImport(kind: .text, content: text))
                } else {
                    // Normal URL (recipe site) or social URL without caption → send URL
                    PendingImportStore.save(PendingImport(kind: .url, content: url))
                }
                self.markSavedAndDismiss()
            } else if let text = foundText {
                PendingImportStore.save(PendingImport(kind: .text, content: text))
                self.markSavedAndDismiss()
            } else if let imageData = foundImageData {
                PendingImportStore.saveImage(imageData)
                self.markSavedAndDismiss()
            } else {
                // Nothing usable was shared — don't claim success.
                self.complete()
            }
        }
    }

    // MARK: - Helpers

    private static let socialHosts: Set<String> = [
        "instagram.com", "www.instagram.com",
        "tiktok.com", "www.tiktok.com", "vm.tiktok.com",
        "twitter.com", "www.twitter.com", "x.com", "www.x.com",
        "facebook.com", "www.facebook.com", "m.facebook.com",
        "threads.net", "www.threads.net",
        "snapchat.com", "www.snapchat.com",
        "youtube.com", "www.youtube.com", "youtu.be", "m.youtube.com",
    ]

    private func isSocialMedia(urlString: String) -> Bool {
        guard let host = URL(string: urlString)?.host?.lowercased() else { return false }
        return Self.socialHosts.contains(host)
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

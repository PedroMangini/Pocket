//
//  DeepLinkHandler.swift
//  Pocket
//
//  Handler para deep links do widget e outras fontes
//

import SwiftUI

enum DeepLink: Equatable {
    case capture
    case box(id: UUID)
    case idea(id: UUID)

    init?(url: URL) {
        guard url.scheme == "pocket" else { return nil }

        switch url.host {
        case "capture":
            self = .capture

        case "box":
            if let idString = url.pathComponents.dropFirst().first,
               let id = UUID(uuidString: idString) {
                self = .box(id: id)
            } else {
                return nil
            }

        case "idea":
            if let idString = url.pathComponents.dropFirst().first,
               let id = UUID(uuidString: idString) {
                self = .idea(id: id)
            } else {
                return nil
            }

        default:
            return nil
        }
    }
}

// MARK: - Deep Link Modifier

struct DeepLinkModifier: ViewModifier {
    @EnvironmentObject var appState: AppState
    @State private var showQuickCapture = false

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
            .sheet(isPresented: $showQuickCapture) {
                QuickCaptureView()
            }
    }

    private func handleDeepLink(url: URL) {
        guard let deepLink = DeepLink(url: url) else { return }

        switch deepLink {
        case .capture:
            // Small delay to ensure the app is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showQuickCapture = true
            }

        case .box(let id):
            appState.selectedBoxId = id

        case .idea:
            // Handle idea deep link
            break
        }
    }
}

extension View {
    func handleDeepLinks() -> some View {
        modifier(DeepLinkModifier())
    }
}

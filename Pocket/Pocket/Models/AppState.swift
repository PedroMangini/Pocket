//
//  AppState.swift
//  Pocket
//
//  Estado global do aplicativo
//

import Foundation
import SwiftUI

final class AppState: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("userName") var userName: String = ""
    @AppStorage("preferredInputMethod") var preferredInputMethod: String = "voice"

    @Published var isCapturing: Bool = false
    @Published var showQuickCapture: Bool = false
    @Published var selectedBoxId: UUID?

    enum InputMethod: String {
        case voice = "voice"
        case text = "text"
    }

    var inputMethod: InputMethod {
        get { InputMethod(rawValue: preferredInputMethod) ?? .voice }
        set { preferredInputMethod = newValue.rawValue }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        userName = ""
    }
}

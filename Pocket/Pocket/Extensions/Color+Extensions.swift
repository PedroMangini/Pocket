//
//  Color+Extensions.swift
//  Pocket
//
//  Extensões para cores do app
//

import SwiftUI

extension Color {
    /// Inicializa uma cor a partir de um nome de cor string
    init(_ name: String) {
        switch name.lowercased() {
        case "blue":
            self = .blue
        case "purple":
            self = .purple
        case "pink":
            self = .pink
        case "red":
            self = .red
        case "orange":
            self = .orange
        case "yellow":
            self = .yellow
        case "green":
            self = .green
        case "mint":
            self = .mint
        case "teal":
            self = .teal
        case "cyan":
            self = .cyan
        case "indigo":
            self = .indigo
        case "gray", "grey":
            self = .gray
        case "brown":
            self = .brown
        default:
            self = .blue
        }
    }
}

// MARK: - App Colors

extension Color {
    static let pocketPrimary = Color.blue
    static let pocketSecondary = Color.purple
    static let pocketAccent = Color.orange

    static let pocketBackground = Color(.systemBackground)
    static let pocketSecondaryBackground = Color(.secondarySystemBackground)

    static let pocketGradient = LinearGradient(
        colors: [.blue, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Box Colors

extension Color {
    static let boxColors: [String: Color] = [
        "blue": .blue,
        "purple": .purple,
        "pink": .pink,
        "red": .red,
        "orange": .orange,
        "yellow": .yellow,
        "green": .green,
        "mint": .mint,
        "teal": .teal,
        "cyan": .cyan,
        "indigo": .indigo,
        "gray": .gray
    ]

    static func forBox(_ colorName: String) -> Color {
        boxColors[colorName.lowercased()] ?? .blue
    }
}

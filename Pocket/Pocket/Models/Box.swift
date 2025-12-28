//
//  Box.swift
//  Pocket
//
//  Caixas para organizar ideias com comportamentos personalizados
//

import Foundation
import SwiftData

/// Tipo de comportamento da caixa
enum BoxBehavior: String, Codable, CaseIterable {
    case notes = "notes"           // Notas padrão - cada ideia vira uma nota
    case list = "list"             // Lista - ideias são itens de lista (ex: mercado)
    case tasks = "tasks"           // Tarefas - ideias viram tasks com checkbox
    case journal = "journal"       // Diário - agrupa por data
    case brainstorm = "brainstorm" // Brainstorm - ideias conectadas visualmente

    var displayName: String {
        switch self {
        case .notes: return "Notas"
        case .list: return "Lista"
        case .tasks: return "Tarefas"
        case .journal: return "Diário"
        case .brainstorm: return "Brainstorm"
        }
    }

    var icon: String {
        switch self {
        case .notes: return "note.text"
        case .list: return "list.bullet"
        case .tasks: return "checkmark.circle"
        case .journal: return "book.closed"
        case .brainstorm: return "lightbulb"
        }
    }

    var description: String {
        switch self {
        case .notes:
            return "Cada ideia se torna uma nota individual"
        case .list:
            return "Ideias são adicionadas como itens de uma lista"
        case .tasks:
            return "Ideias viram tarefas que podem ser marcadas"
        case .journal:
            return "Ideias são agrupadas por data"
        case .brainstorm:
            return "Ideias são conectadas visualmente"
        }
    }
}

/// Palavras-chave para classificação automática
struct BoxKeyword: Codable, Hashable {
    var word: String
    var category: String?
}

@Model
final class Box {
    var id: UUID
    var name: String
    var icon: String
    var color: String
    var behavior: String // BoxBehavior raw value
    var keywords: Data? // Encoded [BoxKeyword]
    var createdAt: Date
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \Idea.box)
    var ideas: [Idea]?

    init(
        name: String,
        icon: String = "folder",
        color: String = "blue",
        behavior: BoxBehavior = .notes,
        keywords: [BoxKeyword] = []
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.behavior = behavior.rawValue
        self.keywords = try? JSONEncoder().encode(keywords)
        self.createdAt = Date()
        self.sortOrder = 0
        self.ideas = []
    }

    var boxBehavior: BoxBehavior {
        get { BoxBehavior(rawValue: behavior) ?? .notes }
        set { behavior = newValue.rawValue }
    }

    var boxKeywords: [BoxKeyword] {
        get {
            guard let data = keywords else { return [] }
            return (try? JSONDecoder().decode([BoxKeyword].self, from: data)) ?? []
        }
        set {
            keywords = try? JSONEncoder().encode(newValue)
        }
    }

    var ideasCount: Int {
        ideas?.count ?? 0
    }
}

// MARK: - Predefined Boxes

extension Box {
    static func createDefaultBoxes() -> [Box] {
        [
            Box(
                name: "Inbox",
                icon: "tray",
                color: "gray",
                behavior: .notes,
                keywords: []
            ),
            Box(
                name: "Mercado",
                icon: "cart",
                color: "green",
                behavior: .list,
                keywords: [
                    BoxKeyword(word: "comprar", category: nil),
                    BoxKeyword(word: "mercado", category: nil),
                    BoxKeyword(word: "supermercado", category: nil)
                ]
            ),
            Box(
                name: "Ideias",
                icon: "lightbulb",
                color: "yellow",
                behavior: .notes,
                keywords: [
                    BoxKeyword(word: "ideia", category: nil),
                    BoxKeyword(word: "pensei", category: nil),
                    BoxKeyword(word: "e se", category: nil)
                ]
            ),
            Box(
                name: "Tarefas",
                icon: "checkmark.circle",
                color: "blue",
                behavior: .tasks,
                keywords: [
                    BoxKeyword(word: "fazer", category: nil),
                    BoxKeyword(word: "lembrar", category: nil),
                    BoxKeyword(word: "preciso", category: nil)
                ]
            )
        ]
    }
}

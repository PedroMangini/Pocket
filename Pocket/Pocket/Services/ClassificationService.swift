//
//  ClassificationService.swift
//  Pocket
//
//  Serviço de classificação automática de ideias usando IA
//

import Foundation
import NaturalLanguage

@MainActor
class ClassificationService: ObservableObject {
    @Published var isProcessing = false

    // Common grocery items in Portuguese
    private let groceryItems: Set<String> = [
        // Frutas
        "maçã", "banana", "laranja", "limão", "abacaxi", "manga", "uva", "morango",
        "melancia", "mamão", "pera", "kiwi", "abacate", "goiaba", "maracujá",
        // Vegetais
        "alface", "tomate", "cebola", "alho", "batata", "cenoura", "brócolis",
        "couve", "espinafre", "pepino", "pimentão", "abobrinha", "berinjela",
        // Proteínas
        "carne", "frango", "peixe", "ovo", "ovos", "presunto", "bacon", "salsicha",
        // Laticínios
        "leite", "queijo", "iogurte", "manteiga", "requeijão", "creme de leite",
        // Grãos e carboidratos
        "arroz", "feijão", "macarrão", "pão", "farinha", "aveia", "granola",
        // Bebidas
        "água", "suco", "refrigerante", "café", "chá", "cerveja", "vinho",
        // Outros
        "açúcar", "sal", "óleo", "azeite", "vinagre", "molho", "ketchup", "mostarda",
        "sabonete", "shampoo", "detergente", "papel higiênico", "sabão"
    ]

    // Task-related keywords
    private let taskKeywords: Set<String> = [
        "fazer", "lembrar", "preciso", "tenho que", "devo", "não esquecer",
        "marcar", "agendar", "ligar", "enviar", "comprar", "pagar", "resolver",
        "terminar", "começar", "revisar", "estudar", "entregar"
    ]

    // Idea-related keywords
    private let ideaKeywords: Set<String> = [
        "ideia", "pensei", "e se", "seria legal", "poderia", "imagina",
        "inspiração", "conceito", "projeto", "criar", "inventar", "inovar"
    ]

    // MARK: - Classification

    func classifyIdea(content: String, boxes: [Box]) -> Box {
        isProcessing = true
        defer { isProcessing = false }

        let lowercased = content.lowercased()

        // 1. Check for grocery items (for "Mercado" box)
        if isGroceryRelated(lowercased) {
            if let groceryBox = boxes.first(where: {
                $0.boxBehavior == .list &&
                ($0.name.lowercased().contains("mercado") ||
                 $0.name.lowercased().contains("compras"))
            }) {
                return groceryBox
            }
        }

        // 2. Check for task-related content
        if isTaskRelated(lowercased) {
            if let taskBox = boxes.first(where: { $0.boxBehavior == .tasks }) {
                return taskBox
            }
        }

        // 3. Check for idea-related content
        if isIdeaRelated(lowercased) {
            if let ideaBox = boxes.first(where: {
                $0.name.lowercased().contains("ideia") ||
                $0.boxBehavior == .brainstorm
            }) {
                return ideaBox
            }
        }

        // 4. Check box keywords
        for box in boxes {
            let keywords = box.boxKeywords
            for keyword in keywords {
                if lowercased.contains(keyword.word.lowercased()) {
                    return box
                }
            }
        }

        // 5. Use NLP to analyze sentiment and entities
        if let classifiedBox = classifyUsingNLP(content: content, boxes: boxes) {
            return classifiedBox
        }

        // 6. Fallback to Inbox
        return boxes.first(where: { $0.name.lowercased() == "inbox" }) ?? boxes.first!
    }

    // MARK: - Helper Methods

    private func isGroceryRelated(_ text: String) -> Bool {
        // Check if any word is a grocery item
        let words = text.components(separatedBy: .whitespaces)
        for word in words {
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
            if groceryItems.contains(cleanWord) {
                return true
            }
        }

        // Check for grocery-related phrases
        let groceryPhrases = ["lista de compras", "supermercado", "mercado", "comprar"]
        for phrase in groceryPhrases {
            if text.contains(phrase) {
                return true
            }
        }

        return false
    }

    private func isTaskRelated(_ text: String) -> Bool {
        for keyword in taskKeywords {
            if text.contains(keyword) {
                return true
            }
        }
        return false
    }

    private func isIdeaRelated(_ text: String) -> Bool {
        for keyword in ideaKeywords {
            if text.contains(keyword) {
                return true
            }
        }
        return false
    }

    private func classifyUsingNLP(content: String, boxes: [Box]) -> Box? {
        // Use NLTagger for entity recognition
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = content

        var hasPlaceEntity = false
        var hasPersonEntity = false
        var hasOrganizationEntity = false

        tagger.enumerateTags(
            in: content.startIndex..<content.endIndex,
            unit: .word,
            scheme: .nameType,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, _ in
            if let tag = tag {
                switch tag {
                case .placeName:
                    hasPlaceEntity = true
                case .personalName:
                    hasPersonEntity = true
                case .organizationName:
                    hasOrganizationEntity = true
                default:
                    break
                }
            }
            return true
        }

        // If entities were found, try to match to appropriate boxes
        if hasPersonEntity || hasOrganizationEntity {
            // Could be a contact or meeting note
            if let box = boxes.first(where: {
                $0.name.lowercased().contains("contato") ||
                $0.name.lowercased().contains("reunião") ||
                $0.name.lowercased().contains("meeting")
            }) {
                return box
            }
        }

        if hasPlaceEntity {
            // Could be a travel or location note
            if let box = boxes.first(where: {
                $0.name.lowercased().contains("viagem") ||
                $0.name.lowercased().contains("lugar")
            }) {
                return box
            }
        }

        return nil
    }

    // MARK: - Smart List Processing

    /// Processes input for list-type boxes (like grocery lists)
    /// Returns individual items extracted from the input
    func extractListItems(from content: String) -> [String] {
        var items: [String] = []

        // Split by common delimiters
        let delimiters = CharacterSet(charactersIn: ",;\n")
        let rawItems = content.components(separatedBy: delimiters)

        for rawItem in rawItems {
            let trimmed = rawItem.trimmingCharacters(in: .whitespacesAndNewlines)

            // Skip empty items
            guard !trimmed.isEmpty else { continue }

            // Remove common prefixes like "e", "também", numbers
            var cleanItem = trimmed
                .replacingOccurrences(of: "^\\d+\\.?\\s*", with: "", options: .regularExpression)
                .replacingOccurrences(of: "^-\\s*", with: "", options: .regularExpression)
                .replacingOccurrences(of: "^e\\s+", with: "", options: .regularExpression)
                .replacingOccurrences(of: "^também\\s+", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if !cleanItem.isEmpty {
                // Capitalize first letter
                cleanItem = cleanItem.prefix(1).uppercased() + cleanItem.dropFirst()
                items.append(cleanItem)
            }
        }

        // If no delimiters were found, the whole content might be a single item
        if items.isEmpty && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let item = content.trimmingCharacters(in: .whitespacesAndNewlines)
            items.append(item.prefix(1).uppercased() + item.dropFirst())
        }

        return items
    }
}

// MARK: - AI Classification (for future OpenAI/Claude integration)

extension ClassificationService {
    /// Placeholder for future AI-powered classification
    /// This would call an external API for more sophisticated classification
    func classifyWithAI(content: String, boxes: [Box]) async throws -> Box {
        // TODO: Implement API call to OpenAI/Claude for classification
        // For now, use local classification
        return classifyIdea(content: content, boxes: boxes)
    }
}

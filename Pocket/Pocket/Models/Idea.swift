//
//  Idea.swift
//  Pocket
//
//  Representa uma ideia capturada
//

import Foundation
import SwiftData

/// Tipo de entrada da ideia
enum IdeaInputType: String, Codable {
    case text = "text"
    case voice = "voice"
    case widget = "widget"
}

/// Status para ideias do tipo task
enum IdeaStatus: String, Codable {
    case active = "active"
    case completed = "completed"
    case archived = "archived"
}

@Model
final class Idea {
    var id: UUID
    var content: String
    var inputType: String // IdeaInputType raw value
    var status: String // IdeaStatus raw value
    var createdAt: Date
    var updatedAt: Date
    var audioURL: String?
    var transcription: String?
    var metadata: Data? // JSON encoded metadata

    var box: Box?

    init(
        content: String,
        inputType: IdeaInputType = .text,
        box: Box? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.inputType = inputType.rawValue
        self.status = IdeaStatus.active.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        self.box = box
    }

    var ideaInputType: IdeaInputType {
        get { IdeaInputType(rawValue: inputType) ?? .text }
        set { inputType = newValue.rawValue }
    }

    var ideaStatus: IdeaStatus {
        get { IdeaStatus(rawValue: status) ?? .active }
        set { status = newValue.rawValue }
    }

    var isCompleted: Bool {
        get { ideaStatus == .completed }
        set { ideaStatus = newValue ? .completed : .active }
    }

    func toggleComplete() {
        isCompleted.toggle()
        updatedAt = Date()
    }
}

// MARK: - Metadata Helpers

extension Idea {
    struct IdeaMetadata: Codable {
        var tags: [String]?
        var priority: Int?
        var dueDate: Date?
        var linkedIdeas: [UUID]?
    }

    var ideaMetadata: IdeaMetadata? {
        get {
            guard let data = metadata else { return nil }
            return try? JSONDecoder().decode(IdeaMetadata.self, from: data)
        }
        set {
            metadata = try? JSONEncoder().encode(newValue)
        }
    }
}

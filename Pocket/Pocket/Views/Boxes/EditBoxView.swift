//
//  EditBoxView.swift
//  Pocket
//
//  Editar caixa existente
//

import SwiftUI
import SwiftData

struct EditBoxView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var box: Box

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var selectedBehavior: BoxBehavior
    @State private var keywords: [String]
    @State private var newKeyword = ""

    private let icons = [
        "folder", "tray", "cart", "lightbulb", "star",
        "heart", "bookmark", "tag", "flag", "bolt",
        "brain", "doc.text", "list.bullet", "checkmark.circle",
        "music.note", "camera", "map", "gift", "house", "briefcase"
    ]

    private let colors = [
        "blue", "purple", "pink", "red", "orange",
        "yellow", "green", "mint", "teal", "cyan", "indigo", "gray"
    ]

    init(box: Box) {
        self.box = box
        _name = State(initialValue: box.name)
        _selectedIcon = State(initialValue: box.icon)
        _selectedColor = State(initialValue: box.color)
        _selectedBehavior = State(initialValue: box.boxBehavior)
        _keywords = State(initialValue: box.boxKeywords.map { $0.word })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome da caixa", text: $name)
                } header: {
                    Text("Nome")
                }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedIcon == icon ? Color(selectedColor).opacity(0.2) : Color.clear)
                                    }
                                    .overlay {
                                        if selectedIcon == icon {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(selectedColor), lineWidth: 2)
                                        }
                                    }
                            }
                            .foregroundStyle(selectedIcon == icon ? Color(selectedColor) : .secondary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Ícone")
                }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        if selectedColor == color {
                                            Circle()
                                                .stroke(.white, lineWidth: 3)
                                                .padding(4)
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Cor")
                }

                Section {
                    ForEach(BoxBehavior.allCases, id: \.self) { behavior in
                        Button {
                            selectedBehavior = behavior
                        } label: {
                            HStack {
                                Image(systemName: behavior.icon)
                                    .foregroundStyle(Color(selectedColor))
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(behavior.displayName)
                                        .foregroundStyle(.primary)
                                    Text(behavior.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if selectedBehavior == behavior {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color(selectedColor))
                                }
                            }
                        }
                    }
                } header: {
                    Text("Comportamento")
                }

                Section {
                    HStack {
                        TextField("Adicionar palavra-chave", text: $newKeyword)

                        Button {
                            addKeyword()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color(selectedColor))
                        }
                        .disabled(newKeyword.isEmpty)
                    }

                    if !keywords.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(keywords, id: \.self) { keyword in
                                KeywordTag(keyword: keyword, color: selectedColor) {
                                    keywords.removeAll { $0 == keyword }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Palavras-chave")
                }
            }
            .navigationTitle("Editar Caixa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addKeyword() {
        let trimmed = newKeyword.trimmingCharacters(in: .whitespaces).lowercased()
        if !trimmed.isEmpty && !keywords.contains(trimmed) {
            keywords.append(trimmed)
        }
        newKeyword = ""
    }

    private func saveChanges() {
        box.name = name
        box.icon = selectedIcon
        box.color = selectedColor
        box.boxBehavior = selectedBehavior
        box.boxKeywords = keywords.map { BoxKeyword(word: $0, category: nil) }
        dismiss()
    }
}

#Preview {
    EditBoxView(box: Box(name: "Teste", icon: "star", color: "blue", behavior: .notes))
}

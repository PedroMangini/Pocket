//
//  NewBoxView.swift
//  Pocket
//
//  Criar nova caixa
//

import SwiftUI
import SwiftData

struct NewBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor = "blue"
    @State private var selectedBehavior: BoxBehavior = .notes
    @State private var keywords: [String] = []
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

    var body: some View {
        NavigationStack {
            Form {
                // Name section
                Section {
                    TextField("Nome da caixa", text: $name)
                } header: {
                    Text("Nome")
                }

                // Icon section
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

                // Color section
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

                // Behavior section
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
                } footer: {
                    Text("Define como a IA organiza as ideias nesta caixa")
                }

                // Keywords section
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
                    Text("Palavras-chave para classificação automática")
                } footer: {
                    Text("A IA usará essas palavras para identificar ideias que pertencem a esta caixa")
                }
            }
            .navigationTitle("Nova Caixa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") {
                        createBox()
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

    private func createBox() {
        let box = Box(
            name: name,
            icon: selectedIcon,
            color: selectedColor,
            behavior: selectedBehavior,
            keywords: keywords.map { BoxKeyword(word: $0, category: nil) }
        )
        modelContext.insert(box)
        dismiss()
    }
}

// MARK: - Keyword Tag

struct KeywordTag: View {
    let keyword: String
    let color: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(keyword)
                .font(.caption)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(Color(color).opacity(0.2))
        }
        .foregroundStyle(Color(color))
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: width, height: y + rowHeight)
        }
    }
}

#Preview {
    NewBoxView()
}

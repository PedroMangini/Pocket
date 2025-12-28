//
//  BoxDetailView.swift
//  Pocket
//
//  Visualização detalhada de uma caixa com suas ideias
//

import SwiftUI
import SwiftData

struct BoxDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var box: Box

    @State private var showQuickCapture = false
    @State private var showEditBox = false
    @State private var searchText = ""

    private var filteredIdeas: [Idea] {
        let ideas = box.ideas ?? []
        if searchText.isEmpty {
            return ideas.sorted { $0.createdAt > $1.createdAt }
        }
        return ideas.filter {
            $0.content.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header card
                    headerCard

                    // Search bar
                    searchBar

                    // Content based on behavior
                    contentSection
                }
                .padding()
            }

            // Floating action button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    floatingButton
                }
            }
            .padding()
        }
        .navigationTitle(box.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditBox = true
                    } label: {
                        Label("Editar Caixa", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        deleteBox()
                    } label: {
                        Label("Apagar Caixa", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showQuickCapture) {
            QuickCaptureView(targetBox: box)
        }
        .sheet(isPresented: $showEditBox) {
            EditBoxView(box: box)
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(box.color).opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: box.icon)
                    .font(.title)
                    .foregroundStyle(Color(box.color))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(box.boxBehavior.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(box.ideasCount) itens")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Buscar...", text: $searchText)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        if filteredIdeas.isEmpty {
            EmptyStateView(
                icon: box.icon,
                title: "Caixa vazia",
                subtitle: "Adicione sua primeira ideia tocando no botão abaixo"
            )
            .padding(.top, 40)
        } else {
            switch box.boxBehavior {
            case .list:
                listContent
            case .tasks:
                tasksContent
            default:
                notesContent
            }
        }
    }

    // MARK: - List Content (for shopping lists, etc.)

    private var listContent: some View {
        VStack(spacing: 8) {
            ForEach(filteredIdeas) { idea in
                ListItemRow(idea: idea) {
                    toggleIdeaComplete(idea)
                } onDelete: {
                    deleteIdea(idea)
                }
            }
        }
    }

    // MARK: - Tasks Content

    private var tasksContent: some View {
        VStack(spacing: 8) {
            ForEach(filteredIdeas) { idea in
                TaskItemRow(idea: idea) {
                    toggleIdeaComplete(idea)
                }
            }
        }
    }

    // MARK: - Notes Content

    private var notesContent: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredIdeas) { idea in
                NoteCard(idea: idea)
            }
        }
    }

    // MARK: - Floating Button

    private var floatingButton: some View {
        Button {
            showQuickCapture = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(box.color), Color(box.color).opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .shadow(color: Color(box.color).opacity(0.4), radius: 8, y: 4)
        }
    }

    // MARK: - Actions

    private func toggleIdeaComplete(_ idea: Idea) {
        idea.toggleComplete()
    }

    private func deleteIdea(_ idea: Idea) {
        modelContext.delete(idea)
    }

    private func deleteBox() {
        modelContext.delete(box)
    }
}

// MARK: - List Item Row

struct ListItemRow: View {
    let idea: Idea
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: idea.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(idea.isCompleted ? .green : .secondary)
            }

            Text(idea.content)
                .strikethrough(idea.isCompleted)
                .foregroundStyle(idea.isCompleted ? .secondary : .primary)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        }
    }
}

// MARK: - Task Item Row

struct TaskItemRow: View {
    let idea: Idea
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: idea.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(idea.isCompleted ? .blue : .secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(idea.content)
                    .strikethrough(idea.isCompleted)
                    .foregroundStyle(idea.isCompleted ? .secondary : .primary)

                Text(idea.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        }
    }
}

// MARK: - Note Card

struct NoteCard: View {
    let idea: Idea

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(idea.content)
                .font(.body)

            HStack {
                if idea.ideaInputType == .voice {
                    Label("Voz", systemImage: "waveform")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(idea.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        }
    }
}

#Preview {
    NavigationStack {
        BoxDetailView(box: Box(name: "Teste", icon: "star", color: "blue", behavior: .notes))
    }
}

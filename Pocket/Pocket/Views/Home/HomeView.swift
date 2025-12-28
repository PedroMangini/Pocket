//
//  HomeView.swift
//  Pocket
//
//  Tela principal do app com lista de caixas
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query(sort: \Box.sortOrder) private var boxes: [Box]

    @State private var showQuickCapture = false
    @State private var showNewBox = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Quick capture card
                        QuickCaptureCard {
                            showQuickCapture = true
                        }

                        // Boxes grid
                        boxesSection

                        // Recent ideas
                        recentIdeasSection
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewBox = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showQuickCapture) {
                QuickCaptureView()
            }
            .sheet(isPresented: $showNewBox) {
                NewBoxView()
            }
            .onAppear {
                createDefaultBoxesIfNeeded()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("Pocket")
                .font(.system(size: 36, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Bom dia"
        case 12..<18: return "Boa tarde"
        default: return "Boa noite"
        }
    }

    // MARK: - Boxes

    private var boxesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suas Caixas")
                .font(.headline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(boxes) { box in
                    NavigationLink(destination: BoxDetailView(box: box)) {
                        BoxCard(box: box)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Recent Ideas

    private var recentIdeasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ideias Recentes")
                .font(.headline)
                .foregroundStyle(.secondary)

            if let allIdeas = boxes.flatMap({ $0.ideas ?? [] }).sorted(by: { $0.createdAt > $1.createdAt }).prefix(5),
               !allIdeas.isEmpty {
                ForEach(Array(allIdeas)) { idea in
                    IdeaRow(idea: idea)
                }
            } else {
                EmptyStateView(
                    icon: "lightbulb",
                    title: "Nenhuma ideia ainda",
                    subtitle: "Toque no botão acima para capturar sua primeira ideia"
                )
            }
        }
    }

    // MARK: - Helpers

    private func createDefaultBoxesIfNeeded() {
        guard boxes.isEmpty else { return }

        let defaultBoxes = Box.createDefaultBoxes()
        for (index, box) in defaultBoxes.enumerated() {
            box.sortOrder = index
            modelContext.insert(box)
        }
    }
}

// MARK: - Quick Capture Card

struct QuickCaptureCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Captura Rápida")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("Toque para falar ou escrever")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Box Card

struct BoxCard: View {
    let box: Box

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: box.icon)
                    .font(.title2)
                    .foregroundStyle(Color(box.color))

                Spacer()

                Text("\(box.ideasCount)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        Capsule()
                            .fill(Color(box.color).opacity(0.2))
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(box.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(box.boxBehavior.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Idea Row

struct IdeaRow: View {
    let idea: Idea

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: idea.ideaInputType == .voice ? "waveform" : "text.alignleft")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(idea.content)
                    .font(.body)
                    .lineLimit(2)

                HStack {
                    if let box = idea.box {
                        Text(box.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background {
                                Capsule()
                                    .fill(Color(box.color).opacity(0.2))
                            }
                    }

                    Text(idea.createdAt.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(.tertiary)

            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}

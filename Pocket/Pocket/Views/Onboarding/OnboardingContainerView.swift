//
//  OnboardingContainerView.swift
//  Pocket
//
//  Container para o fluxo de onboarding
//

import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep = 0
    @State private var userName = ""
    @State private var selectedBoxes: Set<String> = ["inbox", "ideias"]
    @State private var customBoxes: [OnboardingBox] = []

    private let totalSteps = 4

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Progress indicator
                progressIndicator
                    .padding(.top)

                // Content
                TabView(selection: $currentStep) {
                    WelcomeStep(userName: $userName)
                        .tag(0)

                    ConceptStep()
                        .tag(1)

                    BoxesStep(selectedBoxes: $selectedBoxes, customBoxes: $customBoxes)
                        .tag(2)

                    ReadyStep()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // Navigation buttons
                navigationButtons
                    .padding()
            }
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button {
                    withAnimation {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Voltar")
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                if currentStep < totalSteps - 1 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    completeOnboarding()
                }
            } label: {
                HStack {
                    Text(currentStep == totalSteps - 1 ? "Começar" : "Próximo")
                    if currentStep < totalSteps - 1 {
                        Image(systemName: "chevron.right")
                    }
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .disabled(currentStep == 0 && userName.isEmpty)
            .opacity(currentStep == 0 && userName.isEmpty ? 0.5 : 1.0)
        }
    }

    // MARK: - Complete Onboarding

    private func completeOnboarding() {
        appState.userName = userName

        // Create selected predefined boxes
        var sortOrder = 0

        if selectedBoxes.contains("inbox") {
            let inbox = Box(name: "Inbox", icon: "tray", color: "gray", behavior: .notes)
            inbox.sortOrder = sortOrder
            modelContext.insert(inbox)
            sortOrder += 1
        }

        if selectedBoxes.contains("mercado") {
            let mercado = Box(
                name: "Mercado",
                icon: "cart",
                color: "green",
                behavior: .list,
                keywords: [
                    BoxKeyword(word: "comprar", category: nil),
                    BoxKeyword(word: "mercado", category: nil),
                    BoxKeyword(word: "supermercado", category: nil)
                ]
            )
            mercado.sortOrder = sortOrder
            modelContext.insert(mercado)
            sortOrder += 1
        }

        if selectedBoxes.contains("ideias") {
            let ideias = Box(
                name: "Ideias",
                icon: "lightbulb",
                color: "yellow",
                behavior: .notes,
                keywords: [
                    BoxKeyword(word: "ideia", category: nil),
                    BoxKeyword(word: "pensei", category: nil)
                ]
            )
            ideias.sortOrder = sortOrder
            modelContext.insert(ideias)
            sortOrder += 1
        }

        if selectedBoxes.contains("tarefas") {
            let tarefas = Box(
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
            tarefas.sortOrder = sortOrder
            modelContext.insert(tarefas)
            sortOrder += 1
        }

        // Create custom boxes
        for customBox in customBoxes {
            let box = Box(
                name: customBox.name,
                icon: customBox.icon,
                color: customBox.color,
                behavior: customBox.behavior,
                keywords: customBox.keywords.map { BoxKeyword(word: $0, category: nil) }
            )
            box.sortOrder = sortOrder
            modelContext.insert(box)
            sortOrder += 1
        }

        appState.completeOnboarding()
    }
}

// MARK: - Onboarding Box Model

struct OnboardingBox: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var color: String
    var behavior: BoxBehavior
    var keywords: [String]
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AppState())
}

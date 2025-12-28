//
//  OnboardingSteps.swift
//  Pocket
//
//  Steps individuais do onboarding
//

import SwiftUI

// MARK: - Welcome Step

struct WelcomeStep: View {
    @Binding var userName: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Logo / Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 12) {
                Text("Bem-vindo ao")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Pocket")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Where ideas are born")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .italic()
            }

            Spacer()

            // Name input
            VStack(alignment: .leading, spacing: 8) {
                Text("Como podemos te chamar?")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                TextField("Seu nome", text: $userName)
                    .font(.title3)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Concept Step

struct ConceptStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Illustration
            ZStack {
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3 - Double(i) * 0.1), .purple.opacity(0.3 - Double(i) * 0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200 - CGFloat(i * 20), height: 150 - CGFloat(i * 15))
                        .offset(y: CGFloat(i * 20))
                }

                Image(systemName: "bolt.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .offset(y: -20)
            }

            VStack(spacing: 16) {
                Text("Capture em menos de 2 segundos")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Widget na tela de bloqueio para capturar ideias instantaneamente. Fale ou digite - a IA organiza automaticamente.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()

            // Features list
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "mic.fill",
                    title: "Captura por voz",
                    subtitle: "Fale sua ideia e ela é transcrita"
                )

                FeatureRow(
                    icon: "sparkles",
                    title: "IA inteligente",
                    subtitle: "Organização automática em caixas"
                )

                FeatureRow(
                    icon: "rectangle.on.rectangle",
                    title: "Widget rápido",
                    subtitle: "Acesse direto da tela de bloqueio"
                )
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Boxes Step

struct BoxesStep: View {
    @Binding var selectedBoxes: Set<String>
    @Binding var customBoxes: [OnboardingBox]

    @State private var showNewBox = false

    private let predefinedBoxes: [(id: String, name: String, icon: String, color: String, description: String)] = [
        ("inbox", "Inbox", "tray", "gray", "Caixa de entrada padrão"),
        ("mercado", "Mercado", "cart", "green", "Lista de compras inteligente"),
        ("ideias", "Ideias", "lightbulb", "yellow", "Suas inspirações"),
        ("tarefas", "Tarefas", "checkmark.circle", "blue", "To-dos e lembretes")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Configure suas caixas")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Escolha as caixas iniciais e adicione suas próprias")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Predefined boxes
                VStack(spacing: 12) {
                    Text("Caixas sugeridas")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(predefinedBoxes, id: \.id) { box in
                        BoxSelectionRow(
                            name: box.name,
                            icon: box.icon,
                            color: box.color,
                            description: box.description,
                            isSelected: selectedBoxes.contains(box.id)
                        ) {
                            if selectedBoxes.contains(box.id) {
                                selectedBoxes.remove(box.id)
                            } else {
                                selectedBoxes.insert(box.id)
                            }
                        }
                    }
                }

                // Custom boxes
                VStack(spacing: 12) {
                    HStack {
                        Text("Suas caixas")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            showNewBox = true
                        } label: {
                            Label("Adicionar", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                        }
                    }

                    if customBoxes.isEmpty {
                        Text("Toque em adicionar para criar uma caixa personalizada")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .padding()
                    } else {
                        ForEach(customBoxes) { box in
                            BoxSelectionRow(
                                name: box.name,
                                icon: box.icon,
                                color: box.color,
                                description: box.behavior.displayName,
                                isSelected: true
                            ) {
                                customBoxes.removeAll { $0.id == box.id }
                            }
                        }
                    }
                }

                // Example explanation
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Dica")
                        .font(.headline)

                    Text("A caixa **Mercado** é especial: ao dizer \"banana\", a IA entende que é um item de compras e adiciona à lista automaticamente, em vez de criar uma nota separada.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                }
            }
            .padding()
        }
        .sheet(isPresented: $showNewBox) {
            OnboardingNewBoxView { box in
                customBoxes.append(box)
            }
        }
    }
}

struct BoxSelectionRow: View {
    let name: String
    let icon: String
    let color: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color(color))
                    .frame(width: 40, height: 40)
                    .background {
                        Circle()
                            .fill(Color(color).opacity(0.1))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .blue : .gray.opacity(0.3))
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        }
                    }
            }
        }
    }
}

// MARK: - Onboarding New Box View

struct OnboardingNewBoxView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor = "blue"
    @State private var selectedBehavior: BoxBehavior = .notes
    @State private var keywords: [String] = []
    @State private var newKeyword = ""

    let onCreate: (OnboardingBox) -> Void

    private let icons = [
        "folder", "tray", "cart", "lightbulb", "star",
        "heart", "bookmark", "tag", "flag", "bolt"
    ]

    private let colors = [
        "blue", "purple", "pink", "red", "orange",
        "yellow", "green", "mint", "teal", "cyan"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Nome") {
                    TextField("Nome da caixa", text: $name)
                }

                Section("Ícone") {
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
                            }
                            .foregroundStyle(selectedIcon == icon ? Color(selectedColor) : .secondary)
                        }
                    }
                }

                Section("Cor") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        if selectedColor == color {
                                            Circle()
                                                .stroke(.white, lineWidth: 2)
                                                .padding(3)
                                        }
                                    }
                            }
                        }
                    }
                }

                Section("Comportamento") {
                    ForEach(BoxBehavior.allCases, id: \.self) { behavior in
                        Button {
                            selectedBehavior = behavior
                        } label: {
                            HStack {
                                Image(systemName: behavior.icon)
                                    .frame(width: 24)

                                VStack(alignment: .leading) {
                                    Text(behavior.displayName)
                                        .foregroundStyle(.primary)
                                    Text(behavior.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if selectedBehavior == behavior {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                Section("Palavras-chave") {
                    HStack {
                        TextField("Nova palavra", text: $newKeyword)
                        Button {
                            let trimmed = newKeyword.trimmingCharacters(in: .whitespaces).lowercased()
                            if !trimmed.isEmpty && !keywords.contains(trimmed) {
                                keywords.append(trimmed)
                                newKeyword = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
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
                    }
                }
            }
            .navigationTitle("Nova Caixa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") {
                        let box = OnboardingBox(
                            name: name,
                            icon: selectedIcon,
                            color: selectedColor,
                            behavior: selectedBehavior,
                            keywords: keywords
                        )
                        onCreate(box)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Ready Step

struct ReadyStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Celebration
            ZStack {
                ForEach(0..<8) { i in
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: CGFloat(40 + i * 30), height: CGFloat(40 + i * 30))
                }

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
            }

            VStack(spacing: 16) {
                Text("Tudo pronto!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Suas caixas foram configuradas. Agora você pode capturar ideias rapidamente e deixar a IA organizar tudo para você.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()

            // Quick tip
            VStack(spacing: 12) {
                Text("Próximos passos")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 12) {
                        Text("1.")
                            .fontWeight(.bold)
                        Text("Adicione o widget na tela de bloqueio")
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Text("2.")
                            .fontWeight(.bold)
                        Text("Capture sua primeira ideia")
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Text("3.")
                            .fontWeight(.bold)
                        Text("Veja a IA organizar automaticamente")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

#Preview("Welcome") {
    WelcomeStep(userName: .constant(""))
}

#Preview("Concept") {
    ConceptStep()
}

#Preview("Boxes") {
    BoxesStep(selectedBoxes: .constant(["inbox"]), customBoxes: .constant([]))
}

#Preview("Ready") {
    ReadyStep()
}

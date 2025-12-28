//
//  QuickCaptureView.swift
//  Pocket
//
//  Captura rápida de ideias por texto ou voz
//

import SwiftUI
import SwiftData

struct QuickCaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Box.sortOrder) private var boxes: [Box]

    @StateObject private var speechService = SpeechRecognitionService()
    @StateObject private var classificationService = ClassificationService()

    @State private var inputText = ""
    @State private var isRecording = false
    @State private var selectedBox: Box?
    @State private var showBoxPicker = false
    @State private var captureMode: CaptureMode = .voice

    var targetBox: Box?

    enum CaptureMode {
        case voice
        case text
    }

    init(targetBox: Box? = nil) {
        self.targetBox = targetBox
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Mode selector
                Picker("Modo", selection: $captureMode) {
                    Label("Voz", systemImage: "mic.fill").tag(CaptureMode.voice)
                    Label("Texto", systemImage: "keyboard").tag(CaptureMode.text)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Spacer()

                // Main capture area
                if captureMode == .voice {
                    voiceCaptureView
                } else {
                    textCaptureView
                }

                Spacer()

                // Box selector
                boxSelector

                // Submit button
                submitButton
            }
            .padding()
            .navigationTitle("Captura Rápida")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        speechService.stopRecording()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showBoxPicker) {
                BoxPickerView(selectedBox: $selectedBox, boxes: boxes)
            }
            .onAppear {
                if let target = targetBox {
                    selectedBox = target
                }
            }
            .onChange(of: speechService.transcribedText) { _, newValue in
                inputText = newValue
            }
        }
    }

    // MARK: - Voice Capture

    private var voiceCaptureView: some View {
        VStack(spacing: 32) {
            // Waveform visualization
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isRecording ? [.blue.opacity(0.3), .clear] : [.gray.opacity(0.1), .clear],
                            center: .center,
                            startRadius: 60,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(isRecording ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isRecording)

                Circle()
                    .fill(isRecording ? .blue : .gray.opacity(0.3))
                    .frame(width: 120, height: 120)

                Image(systemName: isRecording ? "waveform" : "mic.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            .onTapGesture {
                toggleRecording()
            }

            // Instructions / Transcribed text
            if inputText.isEmpty {
                Text(isRecording ? "Ouvindo..." : "Toque para falar")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                Text(inputText)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    }
            }
        }
    }

    // MARK: - Text Capture

    private var textCaptureView: some View {
        VStack(spacing: 16) {
            TextEditor(text: $inputText)
                .font(.body)
                .frame(minHeight: 150)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                }
                .overlay {
                    if inputText.isEmpty {
                        Text("Digite sua ideia...")
                            .foregroundStyle(.tertiary)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - Box Selector

    private var boxSelector: some View {
        Button {
            showBoxPicker = true
        } label: {
            HStack {
                if let box = selectedBox {
                    Image(systemName: box.icon)
                        .foregroundStyle(Color(box.color))
                    Text(box.name)
                        .foregroundStyle(.primary)
                } else {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.purple)
                    Text("Classificar automaticamente")
                        .foregroundStyle(.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            }
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            submitIdea()
        } label: {
            Text("Salvar Ideia")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
        }
        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(inputText.isEmpty ? 0.5 : 1.0)
    }

    // MARK: - Actions

    private func toggleRecording() {
        if isRecording {
            speechService.stopRecording()
        } else {
            speechService.startRecording()
        }
        isRecording.toggle()
    }

    private func submitIdea() {
        let content = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }

        // Determine the box
        let targetBox: Box
        if let selected = selectedBox {
            targetBox = selected
        } else {
            // Auto-classify
            targetBox = classificationService.classifyIdea(content: content, boxes: boxes)
        }

        // Create and save the idea
        let idea = Idea(
            content: content,
            inputType: captureMode == .voice ? .voice : .text,
            box: targetBox
        )

        modelContext.insert(idea)

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }
}

// MARK: - Box Picker View

struct BoxPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedBox: Box?
    let boxes: [Box]

    var body: some View {
        NavigationStack {
            List {
                // Auto-classify option
                Button {
                    selectedBox = nil
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.purple)
                            .frame(width: 30)

                        VStack(alignment: .leading) {
                            Text("Classificar automaticamente")
                                .foregroundStyle(.primary)
                            Text("A IA escolhe a melhor caixa")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if selectedBox == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }

                // Boxes
                Section("Caixas") {
                    ForEach(boxes) { box in
                        Button {
                            selectedBox = box
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: box.icon)
                                    .foregroundStyle(Color(box.color))
                                    .frame(width: 30)

                                Text(box.name)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if selectedBox?.id == box.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Escolher Caixa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    QuickCaptureView()
}

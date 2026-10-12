import SwiftUI
import FoundationModels

/// A small, real on-device AI example for iOS 26 and Xcode 26.
/// No OpenAI API key, internet API, or third-party package is needed.
struct ContentView: View {
    @State private var prompt = "Explain actors in Swift with a simple example."
    @State private var answer = "Your model's answer will appear here."
    @State private var isGenerating = false

    private var isModelReady: Bool {
        SystemLanguageModel.default.isAvailable
    }

    private var modelStatus: String {
        switch SystemLanguageModel.default.availability {
        case .available:
            return "Apple Intelligence model is ready on this device."
        case .unavailable(.deviceNotEligible):
            return "This device does not support Apple Intelligence."
        case .unavailable(.modelNotReady):
            return "The model isn't ready yet. Enable Apple Intelligence and let it finish downloading."
        case .unavailable:
            return "The model is unavailable. Check Settings > Apple Intelligence & Siri."
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Apple Foundation Models", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundStyle(.tint)

                        Text("Ask a question and get an answer from the on-device language model.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: isModelReady ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(isModelReady ? .green : .orange)
                        Text(modelStatus)
                            .font(.subheadline)
                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your prompt")
                            .font(.headline)

                        TextEditor(text: $prompt)
                            .scrollContentBackground(.hidden)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                        Text("Try: Explain MVVM, write interview tips, or summarize some text.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        Task { await generateAnswer() }
                    } label: {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(isGenerating ? "Generating…" : "Generate with On-Device AI")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isGenerating || !isModelReady || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Model response")
                            .font(.headline)

                        Text(answer)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("On-Device AI Demo")
        }
    }

    @MainActor
    private func generateAnswer() async {
        guard isModelReady, !isGenerating else { return }
        let text = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isGenerating = true
        answer = ""
        defer { isGenerating = false }

        do {
            // LanguageModelSession keeps an on-device model conversation context.
            let session = LanguageModelSession(instructions: """
                You are a friendly iOS development tutor.
                Answer questions clearly and concisely in plain English.
                When relevant, show a short Swift example.
                """)

            // The request runs asynchronously against Apple's on-device model.
            let response = try await session.respond(to: text)
            answer = response.content
        } catch {
            answer = "Generation failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
}

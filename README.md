# Foundation Models Demo — SwiftUI (Xcode 26)

A minimal **real Apple Foundation Models** sample app. Enter a prompt and generate an answer locally using Apple's `LanguageModelSession` and `SystemLanguageModel`.

## Requirements

- **Xcode 26 or later** (Xcode 27 is **not** required). Xcode 25, 16, 15, etc. don't include the iOS 26 SDK or the FoundationModels framework.
- **iOS 26 or later** for the iPhone/iPad app.
- Apple Intelligence-capable device: for example, **iPhone 15 Pro / 15 Pro Max, iPhone 16 or later**, or iPad with M1/A17 Pro or later as supported by Apple.
- **Apple Intelligence enabled** in Settings > Apple Intelligence & Siri, and model download completed.
- Supported device/Siri language and supported region. For up-to-date requirements, see https://support.apple.com/en-in/121115

## Run

1. Unzip this folder.
2. Open `FoundationModelsDemo.xcodeproj` with **Xcode 26**.
3. Select your iPhone/iPad as the run destination (preferred for reliable real-model testing).
4. In the project settings, under Signing & Capabilities, select your Apple development team if Xcode requires one. You may also need to change the `com.example.FoundationModelsDemo` bundle identifier.
5. Press Command-R.
6. Type a question and tap **Generate with On-Device AI**.

If the Generate button is disabled, read the model availability message shown in the app.

## What to look for in code

- `SystemLanguageModel.default.availability` tells you if on-device AI is ready.
- `LanguageModelSession(instructions:)` creates a session with instructions.
- `try await session.respond(to:)` sends a prompt to the device model.
- `response.content` contains the generated text.

## Notes

- No cloud API key or paid API is involved in this demo.
- The example uses on-device **text generation**, not images, private cloud models, or Core AI.
- Simulator testing can depend on matched OS / simulator / model versions and an Apple-silicon Mac with Apple Intelligence enabled. Running on a supported physical device is recommended.
- This ZIP is a source project. Because it was assembled outside macOS, an actual Xcode build and on-device inference cannot be run or guaranteed in this environment.

## Official docs

- https://developer.apple.com/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models
- https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel
- https://developer.apple.com/documentation/xcode-release-notes/xcode-26-release-notes

## SwiftData example

Open the **SwiftData** tab to add tasks, tap a task to toggle completion, and swipe to delete (or use Edit). Close and relaunch the app to verify that your tasks persist. This tab does not require Apple Intelligence.

See `FoundationModelsDemo/SwiftDataExampleView.swift` for the complete example:

- `@Model` defines the stored `TodoItem` class.
- `.modelContainer(for: TodoItem.self)` in the app sets up persistent storage.
- `@Query` fetches tasks newest first and updates the list when data changes.
- `@Environment(\.modelContext)` provides the context for inserting, updating, and deleting tasks.
- `try modelContext.save()` saves changes explicitly; failures show an alert and roll back the change.
- The preview uses an in-memory container so preview data is temporary.

Official documentation: [ModelContainer](https://developer.apple.com/documentation/swiftdata/modelcontainer) and [ModelContext](https://developer.apple.com/documentation/swiftdata/modelcontext).

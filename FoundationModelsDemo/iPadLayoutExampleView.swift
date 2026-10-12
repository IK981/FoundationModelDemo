import SwiftUI

/// Topics shown in the iPad sidebar. Each one opens a live layout demo.
enum iPadLayoutTopic: String, CaseIterable, Identifiable {
    case splitView = "Split View"
    case sizeClasses = "Size Classes"
    case adaptiveGrid = "Adaptive Grid"
    case inspector = "Inspector"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .splitView: return "sidebar.left"
        case .sizeClasses: return "rectangle.split.2x1"
        case .adaptiveGrid: return "square.grid.2x2"
        case .inspector: return "sidebar.right"
        }
    }

    var summary: String {
        switch self {
        case .splitView:
            return "Use NavigationSplitView so iPad keeps a sidebar and a detail pane side by side."
        case .sizeClasses:
            return "Read horizontalSizeClass to change layout when the window is wide or narrow."
        case .adaptiveGrid:
            return "Use an adaptive grid so cards fill extra iPad width instead of stretching one column."
        case .inspector:
            return "Use inspector for secondary details that sit beside the main content on iPad."
        }
    }
}

/// iPad-first SwiftUI example: sidebar + detail, size-class layout, adaptive grid, and inspector.
struct iPadLayoutExampleView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTopic: iPadLayoutTopic? = .splitView
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showsInspector = true

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(iPadLayoutTopic.allCases, selection: $selectedTopic) { topic in
                Label(topic.rawValue, systemImage: topic.symbol)
                    .tag(topic)
            }
            .navigationTitle("iPad Layout")
            .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } detail: {
            NavigationStack {
                Group {
                    switch selectedTopic {
                    case .splitView:
                        SplitViewExplainer(columnVisibility: $columnVisibility)
                    case .sizeClasses:
                        SizeClassDemo()
                    case .adaptiveGrid:
                        AdaptiveGridDemo()
                    case .inspector:
                        InspectorExplainer(showsInspector: $showsInspector)
                    case nil:
                        ContentUnavailableView(
                            "Choose a topic",
                            systemImage: "ipad.landscape",
                            description: Text("Select an item in the sidebar to see how SwiftUI manages iPad layout.")
                        )
                    }
                }
                .navigationTitle(selectedTopic?.rawValue ?? "Detail")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showsInspector.toggle()
                        } label: {
                            Label(
                                showsInspector ? "Hide Inspector" : "Show Inspector",
                                systemImage: "sidebar.right"
                            )
                        }
                    }
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .inspector(isPresented: $showsInspector) {
            InspectorPane(
                topic: selectedTopic,
                horizontalSizeClass: horizontalSizeClass,
                columnVisibility: columnVisibility
            )
            .inspectorColumnWidth(min: 260, ideal: 300, max: 360)
        }
    }
}

// MARK: - Split view

/// Picker requires Hashable selection; NavigationSplitViewVisibility is not Hashable.
private enum SplitColumnMode: String, CaseIterable, Hashable {
    case all
    case doubleColumn
    case detailOnly

    var visibility: NavigationSplitViewVisibility {
        switch self {
        case .all: return .all
        case .doubleColumn: return .doubleColumn
        case .detailOnly: return .detailOnly
        }
    }

    init(_ visibility: NavigationSplitViewVisibility) {
        switch visibility {
        case .all: self = .all
        case .doubleColumn: self = .doubleColumn
        case .detailOnly: self = .detailOnly
        default: self = .all
        }
    }
}

private struct SplitViewExplainer: View {
    @Binding var columnVisibility: NavigationSplitViewVisibility

    private var columnMode: Binding<SplitColumnMode> {
        Binding(
            get: { SplitColumnMode(columnVisibility) },
            set: { columnVisibility = $0.visibility }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DemoCard(
                    title: "NavigationSplitView",
                    symbol: "sidebar.left",
                    text: "On iPad this view owns the two-column layout. The sidebar stays on the left and the selected topic fills the rest of the window. Rotate the iPad or drag Split View; the columns stay in place unless you hide the sidebar."
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Column visibility")
                        .font(.headline)
                    Text("iPad users expect a persistent sidebar. Toggle visibility here to see the same NavigationSplitView change columns.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("Sidebar", selection: columnMode) {
                        Text("Show all").tag(SplitColumnMode.all)
                        Text("Double column").tag(SplitColumnMode.doubleColumn)
                        Text("Detail only").tag(SplitColumnMode.detailOnly)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Size classes

private struct SizeClassDemo: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DemoCard(
                    title: "horizontalSizeClass",
                    symbol: "rectangle.split.2x1",
                    text: "iPad in full screen is usually .regular width. Slide Over, a narrow Split View, or iPhone is .compact. Read the environment value and switch HStack / VStack instead of checking UIDevice."
                )

                HStack(spacing: 12) {
                    SizeClassBadge(
                        title: "Horizontal",
                        value: horizontalSizeClass == .regular ? "regular" : "compact"
                    )
                    SizeClassBadge(
                        title: "Vertical",
                        value: verticalSizeClass == .regular ? "regular" : "compact"
                    )
                }

                // Same content, different arrangement: side-by-side on iPad, stacked when compact.
                let layout = isRegularWidth
                    ? AnyLayout(HStackLayout(spacing: 16))
                    : AnyLayout(VStackLayout(spacing: 16))

                layout {
                    FeatureTile(
                        title: "Wide window",
                        detail: "Use extra space for a second column, inspector, or wider reading width.",
                        tint: .blue
                    )
                    FeatureTile(
                        title: "Narrow window",
                        detail: "Stack content vertically so it still fits in Split View or Slide Over.",
                        tint: .orange
                    )
                }
            }
            .padding()
            .frame(maxWidth: 900, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct SizeClassBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospaced()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct FeatureTile: View {
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(tint.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "rectangle.portrait.rotate")
                        .foregroundStyle(tint)
                }
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Adaptive grid

private struct AdaptiveGridDemo: View {
    private let columns = [GridItem(.adaptive(minimum: 180, maximum: 280), spacing: 16)]

    private let cards: [(title: String, symbol: String)] = [
        ("Sidebar", "sidebar.left"),
        ("Detail", "doc.text"),
        ("Inspector", "sidebar.right"),
        ("Toolbar", "menubar.rectangle"),
        ("Grid", "square.grid.2x2"),
        ("Keyboard", "keyboard"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DemoCard(
                    title: "LazyVGrid + adaptive columns",
                    symbol: "square.grid.2x2",
                    text: "minimum: 180 lets SwiftUI decide how many columns fit. iPhone often shows 1–2 cards per row; iPad landscape shows more without a separate iPad layout file."
                )

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(cards, id: \.title) { card in
                        VStack(spacing: 10) {
                            Image(systemName: card.symbol)
                                .font(.title)
                                .foregroundStyle(.tint)
                            Text(card.title)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 110)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Inspector

private struct InspectorExplainer: View {
    @Binding var showsInspector: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DemoCard(
                    title: "inspector(isPresented:)",
                    symbol: "sidebar.right",
                    text: "On iPad the inspector is a trailing column next to the detail view. On compact width it becomes a sheet. Use it for metadata, filters, or help so the main canvas stays focused."
                )

                Toggle("Show inspector", isOn: $showsInspector)
                    .padding(16)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct InspectorPane: View {
    let topic: iPadLayoutTopic?
    let horizontalSizeClass: UserInterfaceSizeClass?
    let columnVisibility: NavigationSplitViewVisibility

    var body: some View {
        NavigationStack {
            List {
                Section("Current window") {
                    LabeledContent("Topic", value: topic?.rawValue ?? "None")
                    LabeledContent(
                        "Width class",
                        value: horizontalSizeClass == .regular ? "regular" : "compact"
                    )
                    LabeledContent("Split columns", value: visibilityLabel)
                }

                Section("How iPad UI is managed") {
                    Text(topic?.summary ?? "Select a sidebar topic. SwiftUI then fills the detail column and this inspector.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Inspector")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var visibilityLabel: String {
        switch columnVisibility {
        case .all: return "all"
        case .doubleColumn: return "doubleColumn"
        case .detailOnly: return "detailOnly"
        case .automatic: return "automatic"
        default: return "other"
        }
    }
}

// MARK: - Shared card

private struct DemoCard: View {
    let title: String
    let symbol: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .foregroundStyle(.tint)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("iPad") {
    iPadLayoutExampleView()
}

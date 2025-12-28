//
//  PocketWidget.swift
//  PocketWidget
//
//  Widget de captura rápida para tela de bloqueio
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Widget Entry

struct PocketWidgetEntry: TimelineEntry {
    let date: Date
    let ideasCount: Int
}

// MARK: - Timeline Provider

struct PocketWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PocketWidgetEntry {
        PocketWidgetEntry(date: Date(), ideasCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (PocketWidgetEntry) -> Void) {
        let entry = PocketWidgetEntry(date: Date(), ideasCount: getIdeasCount())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PocketWidgetEntry>) -> Void) {
        let entry = PocketWidgetEntry(date: Date(), ideasCount: getIdeasCount())

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func getIdeasCount() -> Int {
        // Access shared container to get ideas count
        let defaults = UserDefaults(suiteName: "group.com.pocket.app")
        return defaults?.integer(forKey: "ideasCount") ?? 0
    }
}

// MARK: - Widget Views

struct PocketWidgetEntryView: View {
    var entry: PocketWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            accessoryCircularView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryInline:
            accessoryInlineView
        case .systemSmall:
            systemSmallView
        case .systemMedium:
            systemMediumView
        default:
            systemSmallView
        }
    }

    // MARK: - Lock Screen Circular Widget

    private var accessoryCircularView: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 2) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)

                if entry.ideasCount > 0 {
                    Text("\(entry.ideasCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
        }
        .widgetURL(URL(string: "pocket://capture"))
    }

    // MARK: - Lock Screen Rectangular Widget

    private var accessoryRectangularView: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("Pocket")
                    .font(.headline)

                Text("Toque para capturar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if entry.ideasCount > 0 {
                Text("\(entry.ideasCount)")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .widgetURL(URL(string: "pocket://capture"))
    }

    // MARK: - Lock Screen Inline Widget

    private var accessoryInlineView: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
            Text("Capturar ideia")
        }
        .widgetURL(URL(string: "pocket://capture"))
    }

    // MARK: - Home Screen Small Widget

    private var systemSmallView: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)

                Text("Capturar")
                    .font(.headline)
                    .foregroundStyle(.white)

                if entry.ideasCount > 0 {
                    Text("\(entry.ideasCount) ideias")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .widgetURL(URL(string: "pocket://capture"))
    }

    // MARK: - Home Screen Medium Widget

    private var systemMediumView: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 20) {
                // Left side - capture button
                VStack(spacing: 8) {
                    Image(systemName: "mic.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background {
                            Circle()
                                .fill(.white.opacity(0.2))
                        }

                    Text("Falar")
                        .font(.caption)
                        .foregroundStyle(.white)
                }

                VStack(spacing: 8) {
                    Image(systemName: "keyboard")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background {
                            Circle()
                                .fill(.white.opacity(0.2))
                        }

                    Text("Digitar")
                        .font(.caption)
                        .foregroundStyle(.white)
                }

                Spacer()

                // Right side - stats
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Pocket")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("\(entry.ideasCount) ideias")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))

                    Spacer()

                    Text("Toque para capturar")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding()
        }
        .widgetURL(URL(string: "pocket://capture"))
    }
}

// MARK: - Widget Configuration

struct PocketWidget: Widget {
    let kind: String = "PocketWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PocketWidgetProvider()) { entry in
            PocketWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pocket")
        .description("Capture ideias rapidamente")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .systemSmall,
            .systemMedium
        ])
    }
}

// MARK: - Quick Capture Intent

@available(iOS 17.0, *)
struct QuickCaptureIntent: AppIntent {
    static var title: LocalizedStringResource = "Captura Rápida"
    static var description = IntentDescription("Abre a captura rápida do Pocket")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // The app will handle the deep link
        return .result()
    }
}

// MARK: - Interactive Widget (iOS 17+)

@available(iOS 17.0, *)
struct PocketInteractiveWidget: Widget {
    let kind: String = "PocketInteractiveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PocketWidgetProvider()) { entry in
            PocketInteractiveWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pocket Interativo")
        .description("Capture ideias com um toque")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@available(iOS 17.0, *)
struct PocketInteractiveWidgetView: View {
    var entry: PocketWidgetEntry

    var body: some View {
        Button(intent: QuickCaptureIntent()) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)

                Text("Nova Ideia")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ContainerRelativeShape()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Widget Bundle

@main
struct PocketWidgetBundle: WidgetBundle {
    var body: some Widget {
        PocketWidget()
        if #available(iOS 17.0, *) {
            PocketInteractiveWidget()
        }
    }
}

// MARK: - Previews

#Preview("Circular", as: .accessoryCircular) {
    PocketWidget()
} timeline: {
    PocketWidgetEntry(date: Date(), ideasCount: 5)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    PocketWidget()
} timeline: {
    PocketWidgetEntry(date: Date(), ideasCount: 12)
}

#Preview("Small", as: .systemSmall) {
    PocketWidget()
} timeline: {
    PocketWidgetEntry(date: Date(), ideasCount: 8)
}

#Preview("Medium", as: .systemMedium) {
    PocketWidget()
} timeline: {
    PocketWidgetEntry(date: Date(), ideasCount: 15)
}

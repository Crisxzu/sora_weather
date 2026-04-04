import WidgetKit
import SwiftUI

private let appGroupId = "group.fr.dazu.sora-weather"

// MARK: - Data Model

struct WeatherEntry: TimelineEntry {
    let date: Date
    let city: String
    let temp: String
    let condition: String
    let minMax: String
    let iconURL: URL?
}

// MARK: - Timeline Provider

struct WeatherTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), city: "Paris", temp: "18°C",
                     condition: "Ensoleillé", minMax: "12° / 24°", iconURL: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let entry = makeEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func makeEntry() -> WeatherEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let city       = defaults?.string(forKey: "widget_city")      ?? "--"
        let temp       = defaults?.string(forKey: "widget_temp")      ?? "--°"
        let condition  = defaults?.string(forKey: "widget_condition") ?? ""
        let minTemp    = defaults?.string(forKey: "widget_min_temp")  ?? "--°"
        let maxTemp    = defaults?.string(forKey: "widget_max_temp")  ?? "--°"
        let iconURLStr = defaults?.string(forKey: "widget_icon_url")
        let iconURL    = iconURLStr.flatMap { URL(string: $0) }

        return WeatherEntry(
            date: Date(),
            city: city,
            temp: temp,
            condition: condition,
            minMax: "\(minTemp) / \(maxTemp)",
            iconURL: iconURL
        )
    }
}

// MARK: - Widget View

struct WeatherWidgetView: View {
    var entry: WeatherEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Row 1 : ville
            Text(entry.city)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)

            Spacer()

            // Row 2 : température + icône
            HStack(alignment: .center, spacing: 6) {
                Text(entry.temp)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                if let url = entry.iconURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.clear
                    }
                    .frame(width: 44, height: 44)
                }

                Spacer()
            }

            Spacer()

            // Row 3 : condition + min/max
            HStack {
                Text(entry.condition)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
                Spacer()
                Text(entry.minMax)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
    }
}

// MARK: - Widget Configuration

struct WeatherWidgetProvider: Widget {
    let kind: String = "WeatherWidgetProvider"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherTimelineProvider()) { entry in
            WeatherWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.11, green: 0.19, blue: 0.41),
                            Color(red: 0.16, green: 0.30, blue: 0.47)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("Sora Weather")
        .description("Affiche la météo actuelle.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

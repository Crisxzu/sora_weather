import AppIntents
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
    let iconImage: UIImage?
    let isLoading: Bool
    let loadingStartDate: Date?
}

// MARK: - Icon helpers

private func iconCacheURL(for iconURL: String) -> URL? {
    guard let container = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupId
    ) else { return nil }
    let name = URL(string: iconURL)?.lastPathComponent ?? "icon.png"
    return container.appendingPathComponent("widget_icons/\(name)")
}

private func downloadIcon(from urlString: String) async -> UIImage? {
    guard let url = URL(string: urlString),
          let cacheURL = iconCacheURL(for: urlString) else { return nil }

    if FileManager.default.fileExists(atPath: cacheURL.path),
       let data = try? Data(contentsOf: cacheURL) {
        return UIImage(data: data)
    }

    guard let (data, response) = try? await URLSession.shared.data(from: url),
          (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }

    let dir = cacheURL.deletingLastPathComponent()
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    try? data.write(to: cacheURL)
    return UIImage(data: data)
}

// MARK: - Timeline Provider

struct WeatherTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), city: "Paris", temp: "18º",
                     condition: "Ensoleillé", minMax: "12º / 24º", iconImage: nil,
                     isLoading: false, loadingStartDate: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        Task { completion(await makeEntry()) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        Task {
            let entry = await makeEntry()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }

    private func makeEntry() async -> WeatherEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let city       = defaults?.string(forKey: "widget_city")      ?? "--"
        let temp       = defaults?.string(forKey: "widget_temp")      ?? "--º"
        let condition  = defaults?.string(forKey: "widget_condition") ?? ""
        let minTemp    = defaults?.string(forKey: "widget_min_temp")  ?? "--º"
        let maxTemp    = defaults?.string(forKey: "widget_max_temp")  ?? "--º"
        let iconURLStr = defaults?.string(forKey: "widget_icon_url")

        let iconImage = iconURLStr != nil ? await downloadIcon(from: iconURLStr!) : nil
        let isLoading = defaults?.bool(forKey: "widget_loading") ?? false
        let loadingStartInterval = defaults?.double(forKey: "widget_loading_start")
        let loadingStartDate: Date? = (loadingStartInterval ?? 0) > 0
            ? Date(timeIntervalSince1970: loadingStartInterval!)
            : nil

        return WeatherEntry(
            date: Date(),
            city: city,
            temp: temp,
            condition: condition,
            minMax: "\(minTemp) / \(maxTemp)",
            iconImage: iconImage,
            isLoading: isLoading,
            loadingStartDate: loadingStartDate
        )
    }
}

// MARK: - Refresh Intent

struct RefreshWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Weather"
    static var isDiscoverable: Bool = false

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: appGroupId)

        defaults?.set(true, forKey: "widget_loading")
        defaults?.set(Date().timeIntervalSince1970, forKey: "widget_loading_start")
        WidgetCenter.shared.reloadAllTimelines()

        guard let apiLink = defaults?.string(forKey: "widget_api_link"),
              let apiKey  = defaults?.string(forKey: "widget_api_key") else {
            defaults?.set(false, forKey: "widget_loading")
            WidgetCenter.shared.reloadAllTimelines()
            return .result()
        }

        let position   = defaults?.string(forKey: "widget_last_position")
        let langIso    = defaults?.string(forKey: "widget_lang_iso")    ?? "en"
        let unitName   = defaults?.string(forKey: "widget_unit_name")   ?? "celsius"
        let baseIconURL = defaults?.string(forKey: "widget_base_icon_url") ?? ""
        let isFahrenheit = unitName == "fahrenheit"

        var components = URLComponents(string: "\(apiLink)/weather")!
        var queryItems = [URLQueryItem(name: "lang_iso", value: langIso)]
        if let pos = position { queryItems.append(URLQueryItem(name: "position", value: pos)) }
        components.queryItems = queryItems

        guard let url = components.url else {
            WidgetCenter.shared.reloadAllTimelines()
            return .result()
        }

        var request = URLRequest(url: url)
        request.setValue("Api-Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let location  = json["location"]  as? [String: Any],
              let current   = json["current"]   as? [String: Any],
              let condition = current["condition"] as? [String: Any] else {
            defaults?.set(false, forKey: "widget_loading")
            WidgetCenter.shared.reloadAllTimelines()
            return .result()
        }

        func convert(_ raw: Double) -> Int {
            isFahrenheit ? Int((raw * 1.8) + 32) : Int(raw)
        }
        func fmt(_ raw: Double) -> String { "\(convert(raw))º" }

        let city      = location["name"]             as? String  ?? "--"
        let tempRaw   = (current["temp"]             as? Double  ?? 0).rounded()
        let minRaw    = (current["min_temp"]         as? Double  ?? 0).rounded()
        let maxRaw    = (current["max_temp"]         as? Double  ?? 0).rounded()
        let isDay     = current["is_day"]            as? Bool    ?? true
        let condText  = condition["text"]            as? String  ?? ""
        let iconCode  = condition["icon"]            as? Int     ?? 0
        let dayStr    = isDay ? "day" : "night"
        let iconURL   = "\(baseIconURL)/\(dayStr)/\(iconCode).png"

        // Invalider le cache icône pour forcer le re-téléchargement
        if let cacheURL = iconCacheURL(for: iconURL) {
            try? FileManager.default.removeItem(at: cacheURL)
        }
        _ = await downloadIcon(from: iconURL)

        defaults?.set(city,         forKey: "widget_city")
        defaults?.set(fmt(tempRaw), forKey: "widget_temp")
        defaults?.set(condText,     forKey: "widget_condition")
        defaults?.set(fmt(minRaw),  forKey: "widget_min_temp")
        defaults?.set(fmt(maxRaw),  forKey: "widget_max_temp")
        defaults?.set(iconURL,      forKey: "widget_icon_url")
        defaults?.set(false,        forKey: "widget_loading")
        defaults?.set(0.0,          forKey: "widget_loading_start")

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Widget View

struct WeatherWidgetView: View {
    var entry: WeatherEntry

    var body: some View {
        ZStack {
            // Contenu principal
            VStack(alignment: .leading, spacing: 0) {
                // Row 1 : ville + bouton refresh
                HStack {
                    Text(entry.city)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                    Spacer()
                    Button(intent: RefreshWeatherIntent()) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // Row 2 : température + icône
                HStack(alignment: .center, spacing: 6) {
                    Text(entry.temp)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)

                    if let img = entry.iconImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
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

            // Overlay de chargement
            if entry.isLoading, let startDate = entry.loadingStartDate {
                Color.white.opacity(0.55)
                    .ignoresSafeArea()
                ProgressView(
                    timerInterval: startDate...startDate.addingTimeInterval(10),
                    countsDown: false
                ) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                }
                .progressViewStyle(.circular)
                .tint(Color(red: 0.11, green: 0.19, blue: 0.41))
                .scaleEffect(1.4)
            }
        }
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

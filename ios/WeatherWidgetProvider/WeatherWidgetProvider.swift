import AppIntents
import OSLog
import WidgetKit
import SwiftUI

private let logger = Logger(subsystem: "fr.dazu.sora-weather.WeatherWidgetProvider", category: "RefreshIntent")

private let appGroupId = "group.fr.dazu.sora-weather"

// MARK: - Shared location model

/// Une position enregistrée, telle qu'exportée par l'app dans `widget_locations`
/// (JSON dans l'App Group). Sert à la fois à alimenter le sélecteur du widget
/// configurable et à dériver la requête API (city + country, ou GPS).
struct SavedLocation: Codable {
    let type: String        // "gps" | "city"
    let name: String        // libellé court
    let city: String?       // requête ville
    let country: String?    // code pays ISO2
    let display: String     // libellé complet

    var isGps: Bool { type == "gps" }
}

/// Lit et décode `widget_locations` depuis l'App Group.
private func loadSavedLocations() -> [SavedLocation] {
    guard let defaults = UserDefaults(suiteName: appGroupId),
          let raw = defaults.string(forKey: "widget_locations"),
          let data = raw.data(using: .utf8),
          let decoded = try? JSONDecoder().decode([SavedLocation].self, from: data)
    else { return [] }
    return decoded
}

// MARK: - Location options (dynamic dropdown)

/// Fournit dynamiquement la liste des positions au picker du widget configurable.
/// On utilise des String (le `display` de chaque position) plutôt qu'une AppEntity :
/// c'est le pattern qui peuple de façon fiable une liste déroulante dans la config
/// d'un widget, et l'ensemble est petit.
struct LocationOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        loadSavedLocations().map { $0.display }
    }

    func defaultResult() async -> String? {
        loadSavedLocations().first?.display
    }
}

/// Retrouve l'index d'une position à partir de son `display` (ce que porte la config).
private func indexForDisplay(_ display: String?) -> Int? {
    guard let display = display else { return nil }
    return loadSavedLocations().firstIndex { $0.display == display }
}

// MARK: - Widget configuration intent

struct WeatherConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "widget_configuration_title"
    static var description = IntentDescription("widget_configuration_description")

    @Parameter(title: "widget_configuration_location", optionsProvider: LocationOptionsProvider())
    var location: String?
}

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
    /// L'index de position choisi pour ce widget (nil = non configuré / défaut).
    let selectedIndex: Int?
    /// true tant que l'app n'a jamais écrit ses credentials → invite à ouvrir l'app.
    let isEmpty: Bool
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

// MARK: - Weather fetch (shared by refresh intent & timeline)

/// Résultat d'un fetch météo natif.
private struct FetchedWeather {
    let city: String
    let temp: String
    let condition: String
    let minMax: String
    let iconURL: String
}

/// Effectue l'appel API pour une position donnée et renvoie les valeurs formatées.
/// `cityQuery`/`countryCode` non nil → mode ville ; sinon `position` → mode GPS.
private func fetchWeather(
    defaults: UserDefaults,
    cityQuery: String?,
    countryCode: String?,
    position: String?
) async -> FetchedWeather? {
    guard let apiLink = defaults.string(forKey: "widget_api_link"),
          let apiKey  = defaults.string(forKey: "widget_api_key") else {
        logger.error("Missing widget_api_link or widget_api_key")
        return nil
    }

    let langIso     = defaults.string(forKey: "widget_lang_iso")      ?? "en"
    let unitName    = defaults.string(forKey: "widget_unit_name")     ?? "celsius"
    let baseIconURL = defaults.string(forKey: "widget_base_icon_url") ?? ""
    let isFahrenheit = unitName == "fahrenheit"

    let trimmedLink = apiLink.hasSuffix("/") ? String(apiLink.dropLast()) : apiLink
    guard var components = URLComponents(string: "\(trimmedLink)/weather") else { return nil }

    var queryItems = [URLQueryItem(name: "lang_iso", value: langIso)]
    if let city = cityQuery {
        queryItems.append(URLQueryItem(name: "city", value: city))
        if let country = countryCode {
            queryItems.append(URLQueryItem(name: "country_code", value: country))
        }
    } else if let pos = position {
        queryItems.append(URLQueryItem(name: "position", value: pos))
    }
    components.queryItems = queryItems

    guard let url = components.url else { return nil }

    var request = URLRequest(url: url)
    request.setValue("Api-Key \(apiKey)", forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 30
    request.cachePolicy = .reloadIgnoringLocalCacheData

    guard let (data, response) = try? await URLSession.shared.data(for: request),
          (response as? HTTPURLResponse)?.statusCode == 200,
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let location  = json["location"]  as? [String: Any],
          let current   = json["current"]   as? [String: Any],
          let condition = current["condition"] as? [String: Any] else {
        logger.error("Bad response or JSON parse failure")
        return nil
    }

    func convert(_ raw: Double) -> Int { isFahrenheit ? Int((raw * 1.8) + 32) : Int(raw) }
    func fmt(_ raw: Double) -> String { "\(convert(raw))º" }

    let city     = location["name"]     as? String ?? "--"
    let tempRaw  = (current["temp"]     as? Double ?? 0).rounded()
    let minRaw   = (current["min_temp"] as? Double ?? 0).rounded()
    let maxRaw   = (current["max_temp"] as? Double ?? 0).rounded()
    let isDay    = current["is_day"]    as? Bool   ?? true
    let condText = condition["text"]    as? String ?? ""
    let iconCode = condition["icon"]    as? Int    ?? 0
    let dayStr   = isDay ? "day" : "night"
    let iconURL  = "\(baseIconURL)/\(dayStr)/\(iconCode).png"

    return FetchedWeather(
        city: city,
        temp: fmt(tempRaw),
        condition: condText,
        minMax: "\(fmt(minRaw)) / \(fmt(maxRaw))",
        iconURL: iconURL
    )
}

/// Dérive (cityQuery, countryCode, position) à partir de l'index choisi dans la
/// liste des positions. Renvoie nil si l'index est hors liste.
private func resolveQuery(for index: Int?, defaults: UserDefaults)
    -> (city: String?, country: String?, position: String?) {
    let locations = loadSavedLocations()
    // Sans config valide, on retombe sur les clés globales écrites par l'app.
    guard let index = index, index >= 0, index < locations.count else {
        return (
            defaults.string(forKey: "widget_city_query"),
            defaults.string(forKey: "widget_active_country"),
            defaults.string(forKey: "widget_last_position")
        )
    }
    let loc = locations[index]
    if loc.isGps {
        return (nil, nil, defaults.string(forKey: "widget_last_position"))
    }
    return (loc.city, loc.country, nil)
}

// MARK: - Timeline Provider

struct WeatherTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), city: "Paris", temp: "18º",
                     condition: String(localized: "widget_placeholder_condition"),
                     minMax: "12º / 24º", iconImage: nil,
                     isLoading: false, loadingStartDate: nil,
                     selectedIndex: nil, isEmpty: false)
    }

    func snapshot(for configuration: WeatherConfigurationIntent, in context: Context) async -> WeatherEntry {
        await makeEntry(for: configuration)
    }

    func timeline(for configuration: WeatherConfigurationIntent, in context: Context) async -> Timeline<WeatherEntry> {
        let entry = await makeEntry(for: configuration)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func makeEntry(for configuration: WeatherConfigurationIntent) async -> WeatherEntry {
        let defaults = UserDefaults(suiteName: appGroupId)

        // État vide : l'app n'a jamais écrit ses credentials.
        let hasData = !(defaults?.string(forKey: "widget_api_link")?.isEmpty ?? true)
        if !hasData {
            return WeatherEntry(date: Date(), city: "", temp: "", condition: "",
                                minMax: "", iconImage: nil, isLoading: false,
                                loadingStartDate: nil, selectedIndex: nil, isEmpty: true)
        }

        let selectedIndex = indexForDisplay(configuration.location)
        let isLoading = defaults?.bool(forKey: "widget_loading") ?? false
        let loadingStartInterval = defaults?.double(forKey: "widget_loading_start") ?? 0
        let loadingStartDate: Date? = loadingStartInterval > 0
            ? Date(timeIntervalSince1970: loadingStartInterval) : nil

        // Fetch la position propre à ce widget (chaque widget a sa config).
        if let defaults = defaults {
            let q = resolveQuery(for: selectedIndex, defaults: defaults)
            if let weather = await fetchWeather(defaults: defaults,
                                                cityQuery: q.city,
                                                countryCode: q.country,
                                                position: q.position) {
                let icon = await downloadIcon(from: weather.iconURL)
                return WeatherEntry(
                    date: Date(), city: weather.city, temp: weather.temp,
                    condition: weather.condition, minMax: weather.minMax,
                    iconImage: icon, isLoading: false, loadingStartDate: nil,
                    selectedIndex: selectedIndex, isEmpty: false
                )
            }
        }

        // Fallback : dernières données écrites par l'app (mode dégradé si fetch échoue).
        let city      = defaults?.string(forKey: "widget_city")      ?? "--"
        let temp      = defaults?.string(forKey: "widget_temp")      ?? "--º"
        let condition = defaults?.string(forKey: "widget_condition") ?? ""
        let minTemp   = defaults?.string(forKey: "widget_min_temp")  ?? "--º"
        let maxTemp   = defaults?.string(forKey: "widget_max_temp")  ?? "--º"
        let iconURLStr = defaults?.string(forKey: "widget_icon_url")
        let iconImage = iconURLStr != nil ? await downloadIcon(from: iconURLStr!) : nil

        return WeatherEntry(
            date: Date(), city: city, temp: temp, condition: condition,
            minMax: "\(minTemp) / \(maxTemp)", iconImage: iconImage,
            isLoading: isLoading, loadingStartDate: loadingStartDate,
            selectedIndex: selectedIndex, isEmpty: false
        )
    }
}

// MARK: - Refresh Intent

struct RefreshWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "widget_refresh_action"
    static var isDiscoverable: Bool = false

    func perform() async throws -> some IntentResult {
        logger.info("perform() started")
        guard let defaults = UserDefaults(suiteName: appGroupId) else {
            logger.error("UserDefaults(suiteName:) returned nil — App Group not accessible")
            return .result()
        }

        defaults.set(true, forKey: "widget_loading")
        defaults.set(Date().timeIntervalSince1970, forKey: "widget_loading_start")
        WidgetCenter.shared.reloadAllTimelines()

        // Le bouton refresh rafraîchit la position active courante (clés globales).
        let q = resolveQuery(for: nil, defaults: defaults)
        guard let weather = await fetchWeather(defaults: defaults,
                                               cityQuery: q.city,
                                               countryCode: q.country,
                                               position: q.position) else {
            defaults.set(false, forKey: "widget_loading")
            WidgetCenter.shared.reloadAllTimelines()
            return .result()
        }

        if let cacheURL = iconCacheURL(for: weather.iconURL) {
            try? FileManager.default.removeItem(at: cacheURL)
        }
        _ = await downloadIcon(from: weather.iconURL)

        defaults.set(weather.city,      forKey: "widget_city")
        defaults.set(weather.temp,      forKey: "widget_temp")
        defaults.set(weather.condition, forKey: "widget_condition")
        defaults.set(weather.iconURL,   forKey: "widget_icon_url")
        // min/max sont déjà formatés ensemble dans minMax — on les resplit pas ici,
        // l'app réécrira les clés séparées au prochain passage.
        defaults.set(false,             forKey: "widget_loading")
        defaults.set(0.0,               forKey: "widget_loading_start")

        logger.info("Data saved: city=\(weather.city)")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Widget View

struct WeatherWidgetView: View {
    var entry: WeatherEntry

    var body: some View {
        ZStack {
            if entry.isEmpty {
                emptyState
            } else {
                content
                loadingOverlay
            }
        }
    }

    private var content: some View {
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
    }

    @ViewBuilder
    private var loadingOverlay: some View {
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

    private var emptyState: some View {
        VStack(spacing: 6) {
            Text("Kumi Weather")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            Text("widget_empty_message")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(16)
    }
}

// MARK: - Widget Configuration

struct WeatherWidgetProvider: Widget {
    let kind: String = "WeatherWidgetProvider"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: WeatherConfigurationIntent.self,
            provider: WeatherTimelineProvider()
        ) { entry in
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
        .configurationDisplayName("Kumi Weather")
        .description("widget_description")
        .supportedFamilies([.systemMedium])
    }
}

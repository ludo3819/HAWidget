import WidgetKit
import SwiftUI

/// TimelineEntry pour le widget
struct HAWidgetEntry: TimelineEntry {
    let date: Date
    let entities: [Entity]
    let error: String?
    let isLoading: Bool
}

/// Provider pour gérer le timeline du widget
struct HAWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> HAWidgetEntry {
        HAWidgetEntry(
            date: Date(),
            entities: [],
            error: nil,
            isLoading: true
        )
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> HAWidgetEntry {
        return HAWidgetEntry(
            date: Date(),
            entities: [],
            error: nil,
            isLoading: true
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<HAWidgetEntry> {
        // Charger la configuration depuis Keychain
        let keychain = KeychainStorage.shared
        
        guard let baseURL = keychain.getBaseURL(),
              let accessToken = keychain.getAccessToken() else {
            let entry = HAWidgetEntry(
                date: Date(),
                entities: [],
                error: "Non configuré",
                isLoading: false
            )
            return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        }
        
        let config = HAConfig(baseURL: baseURL, accessToken: accessToken)
        let api = HomeAssistantAPI(config: config)
        
        do {
            let states = try await api.getStates()
            
            let entry = HAWidgetEntry(
                date: Date(),
                entities: states,
                error: nil,
                isLoading: false
            )
            
            // Actualiser toutes les 30 secondes
            return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(30)))
        } catch let error as HAError {
            let entry = HAWidgetEntry(
                date: Date(),
                entities: [],
                error: error.localizedDescription,
                isLoading: false
            )
            
            return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
        } catch {
            let entry = HAWidgetEntry(
                date: Date(),
                entities: [],
                error: "Erreur",
                isLoading: false
            )
            
            return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
        }
    }
}

/// Configuration intent pour le widget
struct ConfigurationAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Configure le widget HAWidget")
}

/// Widget principal
struct HAWidget: Widget {
    let kind: String = "HAWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: HAWidgetProvider()
        ) { entry in
            HAWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Home Assistant")
        .description("Contrôlez vos entités HA")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

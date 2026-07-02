import SwiftUI

@main
struct HAWidgetApp: App {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            if coordinator.isConfigured {
                ContentView()
                    .environmentObject(coordinator)
            } else {
                SettingsView()
                    .environmentObject(coordinator)
            }
        }
    }
}

/// Coordinateur pour gérer l'état global de l'app
@MainActor
class AppCoordinator: NSObject, ObservableObject {
    @Published var config: HAConfig?
    @Published var isConfigured: Bool = false
    @Published var error: HAError?
    
    override init() {
        super.init()
        loadConfiguration()
    }
    
    /// Charger la configuration depuis Keychain
    private func loadConfiguration() {
        let keychain = KeychainStorage.shared
        
        if let baseURL = keychain.getBaseURL(),
           let accessToken = keychain.getAccessToken() {
            self.config = HAConfig(baseURL: baseURL, accessToken: accessToken)
            self.isConfigured = true
        }
    }
    
    /// Sauvegarder la configuration
    func saveConfiguration(_ config: HAConfig) {
        let keychain = KeychainStorage.shared
        
        do {
            try keychain.saveBaseURL(config.baseURL)
            try keychain.saveAccessToken(config.accessToken)
            
            self.config = config
            self.isConfigured = true
        } catch {
            self.error = .invalidConfiguration
        }
    }
    
    /// Réinitialiser la configuration
    func resetConfiguration() {
        let keychain = KeychainStorage.shared
        
        do {
            try keychain.deleteAll()
            self.config = nil
            self.isConfigured = false
        } catch {
            self.error = .invalidConfiguration
        }
    }
}

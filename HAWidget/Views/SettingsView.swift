import SwiftUI

/// Vue pour configurer la connexion à Home Assistant
struct SettingsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var baseURL: String = ""
    @State private var accessToken: String = ""
    @State private var verifyCertificate: Bool = true
    @State private var isSaving: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Configuration Home Assistant")) {
                    TextField("URL (ex: https://192.168.1.10:8123)", text: $baseURL)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Token d'accès à long terme", text: $accessToken)
                    
                    Toggle("Vérifier le certificat SSL", isOn: $verifyCertificate)
                }
                
                Section(header: Text("Instructions")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Ouvrir Home Assistant")
                        Text("2. Settings → Developer Tools → Token d'accès à long terme")
                        Text("3. Copier le token")
                        Text("4. Coller dans le champ ci-dessus")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Section {
                    Button(action: saveConfiguration) {
                        HStack {
                            if isSaving {
                                ProgressView()
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text("Enregistrer la configuration")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                    }
                    .disabled(isSaving || baseURL.isEmpty || accessToken.isEmpty)
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Configuration")
            .alert("Erreur", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveConfiguration() {
        isSaving = true
        
        let config = HAConfig(
            baseURL: baseURL,
            accessToken: accessToken,
            verifyCertificate: verifyCertificate
        )
        
        // Valider la configuration
        Task {
            do {
                let api = HomeAssistantAPI(config: config)
                _ = try await api.getStates()
                
                // Succès - Sauvegarder
                coordinator.saveConfiguration(config)
                isSaving = false
            } catch let error as HAError {
                errorMessage = error.localizedDescription
                showError = true
                isSaving = false
            } catch {
                errorMessage = "Erreur inconnue"
                showError = true
                isSaving = false
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppCoordinator())
}

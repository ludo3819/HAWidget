import SwiftUI

/// Vue pour afficher et contrôler une entité
struct EntityRowView: View {
    @State var entity: Entity
    let api: HomeAssistantAPI?
    
    @State private var isLoading: Bool = false
    @State private var error: HAError?
    @State private var showError: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icône
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entity.friendlyName)
                    .font(.headline)
                
                Text(entity.entityId)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // État et bouton d'action
            if entity.type == .cover {
                coverControls
            } else {
                switchLightControl
            }
        }
        .contentShape(Rectangle())
        .alert("Erreur", isPresented: $showError) {
            Button("OK") { }
        } message: {
            if let error = error {
                Text(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
    private var switchLightControl: some View {
        HStack(spacing: 8) {
            Text(entity.isOn ? "ON" : "OFF")
                .font(.caption)
                .foregroundColor(entity.isOn ? .green : .gray)
            
            Button(action: toggleEntity) {
                if isLoading {
                    ProgressView()
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: entity.isOn ? "power.circle.fill" : "power.circle")
                        .font(.system(size: 24))
                        .foregroundColor(entity.isOn ? .green : .gray)
                }
            }
            .disabled(isLoading || api == nil)
        }
    }
    
    @ViewBuilder
    private var coverControls: some View {
        VStack(spacing: 4) {
            Text(coverState)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                Button(action: openCover) {
                    Image(systemName: "arrow.up.circle")
                        .font(.system(size: 18))
                }
                .disabled(isLoading || api == nil)
                
                Button(action: stopCover) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: 18))
                }
                .disabled(isLoading || api == nil)
                
                Button(action: closeCover) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 18))
                }
                .disabled(isLoading || api == nil)
            }
        }
    }
    
    // MARK: - Propriétés Calculées
    
    private var iconName: String {
        switch entity.type {
        case .light:
            return entity.isOn ? "lightbulb.fill" : "lightbulb"
        case .switch:
            return entity.isOn ? "power.circle.fill" : "power.circle"
        case .cover:
            return entity.state.lowercased() == "open" ? "arrow.up.right.square" : "arrow.down.left.square"
        default:
            return "circle"
        }
    }
    
    private var iconColor: Color {
        switch entity.type {
        case .light, .switch:
            return entity.isOn ? .green : .gray
        case .cover:
            return entity.state.lowercased() == "open" ? .blue : .orange
        default:
            return .gray
        }
    }
    
    private var coverState: String {
        switch entity.state.lowercased() {
        case "open":
            return "Ouvert"
        case "closed":
            return "Fermé"
        case "opening":
            return "Ouverture..."
        case "closing":
            return "Fermeture..."
        default:
            return entity.state
        }
    }
    
    // MARK: - Actions
    
    private func toggleEntity() {
        isLoading = true
        
        Task {
            do {
                guard let api = api else {
                    error = .invalidConfiguration
                    showError = true
                    isLoading = false
                    return
                }
                
                try await api.toggle(entityId: entity.entityId)
                
                // Mettre à jour l'état local
                DispatchQueue.main.async {
                    entity.state = entity.isOn ? "off" : "on"
                    isLoading = false
                }
            } catch let haError as HAError {
                DispatchQueue.main.async {
                    self.error = haError
                    self.showError = true
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = .networkError(error)
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func openCover() {
        performCoverAction(action: openCoverAction)
    }
    
    private func closeCover() {
        performCoverAction(action: closeCoverAction)
    }
    
    private func stopCover() {
        performCoverAction(action: stopCoverAction)
    }
    
    private func performCoverAction(action: @escaping () async throws -> Void) {
        isLoading = true
        
        Task {
            do {
                try await action()
                
                DispatchQueue.main.async {
                    isLoading = false
                }
            } catch let haError as HAError {
                DispatchQueue.main.async {
                    self.error = haError
                    self.showError = true
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = .networkError(error)
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func openCoverAction() async throws {
        guard let api = api else {
            throw HAError.invalidConfiguration
        }
        try await api.openCover(entityId: entity.entityId)
    }
    
    private func closeCoverAction() async throws {
        guard let api = api else {
            throw HAError.invalidConfiguration
        }
        try await api.closeCover(entityId: entity.entityId)
    }
    
    private func stopCoverAction() async throws {
        guard let api = api else {
            throw HAError.invalidConfiguration
        }
        try await api.stopCover(entityId: entity.entityId)
    }
}

#Preview {
    let mockEntity = Entity(
        id: "switch.lampe_killian",
        entityId: "switch.lampe_killian",
        friendlyName: "Lampe Killian",
        state: "on",
        attributes: ["icon": AnyCodable("mdi:lamp")],
        lastChanged: Date(),
        lastUpdated: Date()
    )
    
    return EntityRowView(entity: mockEntity, api: nil)
}

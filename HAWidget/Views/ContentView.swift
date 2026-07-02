import SwiftUI

/// Vue principale affichant les entités
struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var entities: [Entity] = []
    @State private var isLoading: Bool = false
    @State private var error: HAError?
    @State private var api: HomeAssistantAPI?
    @State private var filteredEntities: [Entity] = []
    @State private var selectedFilter: EntityTypeFilter = .all
    
    enum EntityTypeFilter {
        case all
        case switches
        case lights
        case covers
        
        var title: String {
            switch self {
            case .all: return "Tous"
            case .switches: return "Interrupteurs"
            case .lights: return "Lumières"
            case .covers: return "Stores"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Filtres
                Picker("Type", selection: $selectedFilter) {
                    Text(EntityTypeFilter.all.title).tag(EntityTypeFilter.all)
                    Text(EntityTypeFilter.switches.title).tag(EntityTypeFilter.switches)
                    Text(EntityTypeFilter.lights.title).tag(EntityTypeFilter.lights)
                    Text(EntityTypeFilter.covers.title).tag(EntityTypeFilter.covers)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if filteredEntities.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Aucune entité")
                            .font(.headline)
                        Text("Vérifiez votre configuration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(filteredEntities) { entity in
                            EntityRowView(entity: entity, api: api)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Entités HA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: loadEntities) {
                            Label("Actualiser", systemImage: "arrow.clockwise")
                        }
                        
                        Divider()
                        
                        NavigationLink(destination: SettingsView().environmentObject(coordinator)) {
                            Label("Paramètres", systemImage: "gear")
                        }
                        
                        Button(role: .destructive) {
                            coordinator.resetConfiguration()
                        } label: {
                            Label("Déconnexion", systemImage: "icloud.slash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                if api == nil, let config = coordinator.config {
                    api = HomeAssistantAPI(config: config)
                    loadEntities()
                }
            }
            .onChange(of: entities) { _, _ in
                filterEntities()
            }
            .onChange(of: selectedFilter) { _, _ in
                filterEntities()
            }
        }
    }
    
    private func loadEntities() {
        isLoading = true
        error = nil
        
        Task {
            do {
                guard let api = api else {
                    error = .invalidConfiguration
                    return
                }
                
                let states = try await api.getStates()
                
                DispatchQueue.main.async {
                    self.entities = states.sorted { $0.friendlyName < $1.friendlyName }
                    self.isLoading = false
                }
            } catch let haError as HAError {
                DispatchQueue.main.async {
                    self.error = haError
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = .networkError(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func filterEntities() {
        filteredEntities = entities.filter { entity in
            switch selectedFilter {
            case .all:
                return true
            case .switches:
                return entity.type == .switch
            case .lights:
                return entity.type == .light
            case .covers:
                return entity.type == .cover
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}

# Guide API - HomeAssistantAPI

## Initialisation

```swift
let config = HAConfig(
    baseURL: "https://192.168.1.10:8123",
    accessToken: "eyJ0eXAiOiJKV1QiLCJhbGc..."
)

let api = HomeAssistantAPI(config: config)
```

## Méthodes Disponibles

### Récupérer les États

#### Toutes les entités
```swift
let entities = try await api.getStates()
// Returns: [Entity]
```

#### Une entité spécifique
```swift
let entity = try await api.getState(entityId: "switch.lampe_killian")
// Returns: Entity
```

### Contrôler les Switches/Lights

#### Toggle (Basculer)
```swift
try await api.toggle(entityId: "switch.lampe_killian")
```

#### Turn On (Allumer)
```swift
try await api.turnOn(entityId: "light.salon")
```

#### Turn Off (Éteindre)
```swift
try await api.turnOff(entityId: "light.salon")
```

### Contrôler les Covers (Stores)

#### Open (Ouvrir)
```swift
try await api.openCover(entityId: "cover.amie")
```

#### Close (Fermer)
```swift
try await api.closeCover(entityId: "cover.amie")
```

#### Stop (Arrêter)
```swift
try await api.stopCover(entityId: "cover.amie")
```

## Structures de Données

### Entity
```swift
struct Entity {
    let id: String                          // Identifiant unique
    let entityId: String                    // ID Home Assistant (ex: switch.lampe_killian)
    let friendlyName: String                // Nom affiché
    let state: String                       // État actuel (on, off, open, closed, etc.)
    let attributes: [String: AnyCodable]    // Attributs additionnels
    let lastChanged: Date                   // Dernière modification
    let lastUpdated: Date                   // Dernière mise à jour
    
    var type: EntityType                    // Type détecté (light, switch, cover, etc.)
    var isOn: Bool                          // true si state == "on"
}
```

### HAConfig
```swift
struct HAConfig {
    var baseURL: String
    var accessToken: String
    var verifyCertificate: Bool
}
```

## Gestion des Erreurs

```swift
do {
    try await api.toggle(entityId: "switch.lampe_killian")
} catch let error as HAError {
    switch error {
    case .invalidConfiguration:
        print("Configuration invalide")
    case .unauthorized:
        print("Token incorrect")
    case .notFound:
        print("Entité non trouvée")
    case .networkError(let err):
        print("Erreur réseau: \(err)")
    default:
        print("Erreur: \(error.localizedDescription)")
    }
}
```

## Exemple Complet

```swift
@MainActor
class MyViewModel: ObservableObject {
    @Published var entity: Entity?
    @Published var error: HAError?
    
    private let api: HomeAssistantAPI
    
    init(config: HAConfig) {
        self.api = HomeAssistantAPI(config: config)
    }
    
    func loadEntity(_ entityId: String) {
        Task {
            do {
                self.entity = try await api.getState(entityId: entityId)
            } catch let error as HAError {
                self.error = error
            }
        }
    }
    
    func toggleLight() {
        guard let entity = entity else { return }
        
        Task {
            do {
                try await api.toggle(entityId: entity.entityId)
                // Recharger l'état
                self.entity = try await api.getState(entityId: entity.entityId)
            } catch let error as HAError {
                self.error = error
            }
        }
    }
}
```

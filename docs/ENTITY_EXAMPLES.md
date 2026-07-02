# Exemples d'Entités

## Switch (Interrupteur)

### Exemple 1: Lampe Killian
```yaml
entity_id: switch.lampe_killian
name: Lampe Killian
state: "on"
icon: mdi:lamp
type: EntityType.switch
```

**Code Swift:**
```swift
let lampEntity = Entity(
    id: "switch.lampe_killian",
    entityId: "switch.lampe_killian",
    friendlyName: "Lampe Killian",
    state: "on",
    attributes: ["icon": AnyCodable("mdi:lamp")],
    lastChanged: Date(),
    lastUpdated: Date()
)

// Basculer
try await api.toggle(entityId: "switch.lampe_killian")

// Affichage
print("État: \(lampEntity.isOn ? "Allumée" : "Éteinte")")
```

### Exemple 2: PC Killian
```yaml
entity_id: switch.pc_killian
name: PC Killian
state: "off"
icon: mdi:desktop-windows
type: EntityType.switch
```

**Code Swift:**
```swift
// Allumer le PC
try await api.turnOn(entityId: "switch.pc_killian")

// Attendre un peu
await Task.sleep(2_000_000_000) // 2 secondes

// Récupérer l'état
let pcEntity = try await api.getState(entityId: "switch.pc_killian")
print("PC allumé: \(pcEntity.isOn)")
```

### Exemple 3: Interrupteur Libre
```yaml
entity_id: switch.libre
name: Libre
state: "off"
icon: mdi:lightbulb
type: EntityType.switch
```

**Code Swift:**
```swift
// Allumer
try await api.turnOn(entityId: "switch.libre")

// Récupérer immédiatement
let libreEntity = try await api.getState(entityId: "switch.libre")
print("Libre: \(libreEntity.state)")
```

## Light (Luminaire)

### Exemple 1: Lumière Salon
```yaml
entity_id: light.0xa4c138e492a684d1
name: Salon
state: "on"
attributes:
  brightness: 254
  color_temp: 366
  icon: mdi:lightbulb
type: EntityType.light
```

**Code Swift:**
```swift
let salonLight = Entity(
    id: "light.0xa4c138e492a684d1",
    entityId: "light.0xa4c138e492a684d1",
    friendlyName: "Salon",
    state: "on",
    attributes: [
        "brightness": AnyCodable(254),
        "color_temp": AnyCodable(366)
    ],
    lastChanged: Date(),
    lastUpdated: Date()
)

print("Type: \(salonLight.type)")  // EntityType.light
print("Allumée: \(salonLight.isOn)")  // true

// Éteindre
try await api.turnOff(entityId: "light.0xa4c138e492a684d1")

// Allumer
try await api.turnOn(entityId: "light.0xa4c138e492a684d1")

// Basculer
try await api.toggle(entityId: "light.0xa4c138e492a684d1")
```

### Exemple 2: Lumière Devant
```yaml
entity_id: light.devant
name: Devant
state: "off"
icon: mdi:lightbulb-off
type: EntityType.light
```

**Code Swift:**
```swift
// Avec gestion d'erreur
do {
    try await api.turnOn(entityId: "light.devant")
    let devantLight = try await api.getState(entityId: "light.devant")
    print("Devant allumée: \(devantLight.isOn)")
} catch let error as HAError {
    switch error {
    case .notFound:
        print("Lumière non trouvée")
    case .unauthorized:
        print("Token invalide")
    default:
        print("Erreur: \(error.localizedDescription)")
    }
}
```

## Cover (Store/Volet)

### Exemple 1: Store Amis
```yaml
entity_id: cover.amie
name: Amis
state: "open"
attributes:
  icon: cil:shutter-4
  current_position: 100
type: EntityType.cover
```

**Code Swift:**
```swift
let coverEntity = Entity(
    id: "cover.amie",
    entityId: "cover.amie",
    friendlyName: "Amis",
    state: "open",
    attributes: [
        "icon": AnyCodable("cil:shutter-4"),
        "current_position": AnyCodable(100)
    ],
    lastChanged: Date(),
    lastUpdated: Date()
)

print("Type: \(coverEntity.type)")  // EntityType.cover
print("État: \(coverEntity.state)")  // "open"

// Ouvrir
try await api.openCover(entityId: "cover.amie")

// Fermer
try await api.closeCover(entityId: "cover.amie")

// Arrêter (si en mouvement)
try await api.stopCover(entityId: "cover.amie")
```

### Exemple 2: Affichage d'État
```swift
let states = try await api.getStates()

let covers = states.filter { $0.type == .cover }

for cover in covers {
    let status: String
    switch cover.state.lowercased() {
    case "open":
        status = "Ouvert ✓"
    case "closed":
        status = "Fermé ✗"
    case "opening":
        status = "Ouverture en cours..."
    case "closing":
        status = "Fermeture en cours..."
    default:
        status = cover.state
    }
    
    print("\(cover.friendlyName): \(status)")
}
```

## Filtrage par Type

```swift
// Récupérer toutes les entités
let allEntities = try await api.getStates()

// Filtrer par type
let switches = allEntities.filter { $0.type == .switch }
let lights = allEntities.filter { $0.type == .light }
let covers = allEntities.filter { $0.type == .cover }

print("Interrupteurs: \(switches.count)")
print("Lumières: \(lights.count)")
print("Stores: \(covers.count)")
```

## Gestion des Erreurs

```swift
do {
    try await api.toggle(entityId: "switch.unknown_entity")
} catch let error as HAError {
    switch error {
    case .invalidURL:
        print("❌ URL invalide")
    case .invalidResponse:
        print("❌ Réponse invalide du serveur")
    case .unauthorized:
        print("❌ Token incorrect ou expiré")
    case .notFound:
        print("❌ Entité non trouvée")
    case .serverError(let code):
        print("❌ Erreur serveur \(code)")
    case .networkError(let error):
        print("❌ Erreur réseau: \(error.localizedDescription)")
    case .invalidConfiguration:
        print("❌ Configuration invalide")
    case .decodingError:
        print("❌ Erreur de décodage")
    }
}
```

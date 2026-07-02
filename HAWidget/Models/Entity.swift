import Foundation

/// Représente une entité Home Assistant
struct Entity: Identifiable, Codable {
    let id: String
    let entityId: String
    let friendlyName: String
    let state: String
    let attributes: [String: AnyCodable]
    let lastChanged: Date
    let lastUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case state
        case attributes
        case lastChanged = "last_changed"
        case lastUpdated = "last_updated"
    }
    
    /// Initialiser depuis la réponse API Home Assistant
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.entityId = try container.decode(String.self, forKey: .entityId)
        self.state = try container.decode(String.self, forKey: .state)
        self.attributes = try container.decodeIfPresent([String: AnyCodable].self, forKey: .attributes) ?? [:]
        
        let lastChangedStr = try container.decode(String.self, forKey: .lastChanged)
        let lastUpdatedStr = try container.decode(String.self, forKey: .lastUpdated)
        
        self.lastChanged = ISO8601DateFormatter().date(from: lastChangedStr) ?? Date()
        self.lastUpdated = ISO8601DateFormatter().date(from: lastUpdatedStr) ?? Date()
        
        // Extraire le friendly_name depuis les attributs
        if let friendlyNameAttr = attributes["friendly_name"]?.value as? String {
            self.friendlyName = friendlyNameAttr
        } else {
            self.friendlyName = entityId.split(separator: ".").last.map(String.init) ?? entityId
        }
        
        self.id = entityId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entityId, forKey: .entityId)
        try container.encode(state, forKey: .state)
        try container.encode(attributes, forKey: .attributes)
        
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: lastChanged), forKey: .lastChanged)
        try container.encode(formatter.string(from: lastUpdated), forKey: .lastUpdated)
    }
    
    /// Type d'entité détecté
    var type: EntityType {
        let domain = entityId.split(separator: ".").first.map(String.init) ?? ""
        return EntityType(domain: domain)
    }
    
    /// État booléen pour les switches/lights
    var isOn: Bool {
        state.lowercased() == "on"
    }
}

/// Catégories d'entités supportées
enum EntityType {
    case light
    case switch
    case cover
    case sensor
    case climate
    case unknown
    
    init(domain: String) {
        switch domain.lowercased() {
        case "light":
            self = .light
        case "switch":
            self = .switch
        case "cover":
            self = .cover
        case "sensor":
            self = .sensor
        case "climate":
            self = .climate
        default:
            self = .unknown
        }
    }
}

/// Wrapper pour les valeurs JSON dynamiques
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intVal as Int:
            try container.encode(intVal)
        case let doubleVal as Double:
            try container.encode(doubleVal)
        case let boolVal as Bool:
            try container.encode(boolVal)
        case let stringVal as String:
            try container.encode(stringVal)
        case let arrayVal as [AnyCodable]:
            try container.encode(arrayVal)
        case let dictVal as [String: AnyCodable]:
            try container.encode(dictVal)
        default:
            try container.encodeNil()
        }
    }
}

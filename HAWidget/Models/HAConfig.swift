import Foundation

/// Configuration de connexion à Home Assistant
struct HAConfig: Codable {
    var baseURL: String
    var accessToken: String
    var verifyCertificate: Bool = true
    
    init(baseURL: String, accessToken: String, verifyCertificate: Bool = true) {
        self.baseURL = baseURL
        self.accessToken = accessToken
        self.verifyCertificate = verifyCertificate
    }
    
    /// URL complète de l'API Home Assistant
    var apiURL: URL? {
        var urlString = baseURL
        if !urlString.hasSuffix("/") {
            urlString += "/"
        }
        urlString += "api"
        return URL(string: urlString)
    }
    
    /// Valider la configuration
    func isValid() -> Bool {
        return !baseURL.isEmpty && !accessToken.isEmpty && apiURL != nil
    }
}

/// État d'une entité
struct EntityState: Codable {
    let entityId: String
    let state: String
    let attributes: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case state
        case attributes
    }
}

import Foundation

/// Erreurs possibles lors de la communication avec Home Assistant
enum HAError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case unauthorized
    case notFound
    case serverError(Int)
    case networkError(Error)
    case invalidConfiguration
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .decodingError:
            return "Erreur de décodage des données"
        case .unauthorized:
            return "Token d'accès invalide"
        case .notFound:
            return "Entité non trouvée"
        case .serverError(let code):
            return "Erreur serveur (\(code))"
        case .networkError(let error):
            return "Erreur réseau: \(error.localizedDescription)"
        case .invalidConfiguration:
            return "Configuration Home Assistant invalide"
        }
    }
}

/// Client API pour Home Assistant
actor HomeAssistantAPI {
    private let config: HAConfig
    private let session: URLSession
    
    init(config: HAConfig) {
        self.config = config
        
        // Configuration URLSession
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Entités
    
    /// Récupérer toutes les entités
    /// - Returns: Liste de toutes les entités avec leur état
    func getStates() async throws -> [Entity] {
        guard config.isValid() else {
            throw HAError.invalidConfiguration
        }
        
        guard let url = config.apiURL?.appendingPathComponent("states") else {
            throw HAError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(config.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HAError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                let entities = try decoder.decode([Entity].self, from: data)
                return entities
            case 401:
                throw HAError.unauthorized
            case 404:
                throw HAError.notFound
            default:
                throw HAError.serverError(httpResponse.statusCode)
            }
        } catch let error as HAError {
            throw error
        } catch {
            throw HAError.networkError(error)
        }
    }
    
    /// Récupérer une entité spécifique
    /// - Parameter entityId: ID de l'entité (ex: "switch.lampe_killian")
    /// - Returns: État de l'entité
    func getState(entityId: String) async throws -> Entity {
        guard config.isValid() else {
            throw HAError.invalidConfiguration
        }
        
        guard let url = config.apiURL?.appendingPathComponent("states").appendingPathComponent(entityId) else {
            throw HAError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(config.accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HAError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                let entity = try decoder.decode(Entity.self, from: data)
                return entity
            case 401:
                throw HAError.unauthorized
            case 404:
                throw HAError.notFound
            default:
                throw HAError.serverError(httpResponse.statusCode)
            }
        } catch let error as HAError {
            throw error
        } catch {
            throw HAError.networkError(error)
        }
    }
    
    // MARK: - Services (Actions)
    
    /// Basculer l'état d'un switch ou light
    /// - Parameter entityId: ID de l'entité (ex: "switch.lampe_killian")
    func toggle(entityId: String) async throws {
        try await callService(domain: "homeassistant", service: "toggle", entityId: entityId)
    }
    
    /// Allumer une entité
    /// - Parameter entityId: ID de l'entité
    func turnOn(entityId: String) async throws {
        let domain = entityId.split(separator: ".").first.map(String.init) ?? "switch"
        try await callService(domain: domain, service: "turn_on", entityId: entityId)
    }
    
    /// Éteindre une entité
    /// - Parameter entityId: ID de l'entité
    func turnOff(entityId: String) async throws {
        let domain = entityId.split(separator: ".").first.map(String.init) ?? "switch"
        try await callService(domain: domain, service: "turn_off", entityId: entityId)
    }
    
    /// Ouvrir un cover (store/volet)
    /// - Parameter entityId: ID du cover
    func openCover(entityId: String) async throws {
        try await callService(domain: "cover", service: "open_cover", entityId: entityId)
    }
    
    /// Fermer un cover (store/volet)
    /// - Parameter entityId: ID du cover
    func closeCover(entityId: String) async throws {
        try await callService(domain: "cover", service: "close_cover", entityId: entityId)
    }
    
    /// Arrêter un cover (store/volet)
    /// - Parameter entityId: ID du cover
    func stopCover(entityId: String) async throws {
        try await callService(domain: "cover", service: "stop_cover", entityId: entityId)
    }
    
    // MARK: - Privé
    
    /// Appeler un service Home Assistant
    private func callService(domain: String, service: String, entityId: String) async throws {
        guard config.isValid() else {
            throw HAError.invalidConfiguration
        }
        
        guard let baseURL = config.apiURL else {
            throw HAError.invalidURL
        }
        
        let url = baseURL.appendingPathComponent("services").appendingPathComponent(domain).appendingPathComponent(service)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "entity_id": entityId
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HAError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return
            case 401:
                throw HAError.unauthorized
            case 404:
                throw HAError.notFound
            default:
                throw HAError.serverError(httpResponse.statusCode)
            }
        } catch let error as HAError {
            throw error
        } catch {
            throw HAError.networkError(error)
        }
    }
}

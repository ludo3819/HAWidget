import Foundation
import Security

/// Gestion du stockage sécurisé des données sensibles dans Keychain
class KeychainStorage {
    static let shared = KeychainStorage()
    
    private let service = "com.hawidget.service"
    private let account = "homeassistant"
    
    // MARK: - Token d'Accès
    
    /// Sauvegarder le token d'accès
    func saveAccessToken(_ token: String) throws {
        let data = token.data(using: .utf8) ?? Data()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: account + ".token",
            kSecValueData as String: data
        ]
        
        // Supprimer l'ancienne valeur si elle existe
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    /// Récupérer le token d'accès
    func getAccessToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: account + ".token",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    /// Supprimer le token d'accès
    func deleteAccessToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: account + ".token"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
    
    // MARK: - URL de Base
    
    /// Sauvegarder l'URL de base
    func saveBaseURL(_ url: String) throws {
        let data = url.data(using: .utf8) ?? Data()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: account + ".url",
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    /// Récupérer l'URL de base
    func getBaseURL() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: account + ".url",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let url = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return url
    }
    
    /// Supprimer l'URL de base
    func deleteBaseURL() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecService as String: service,
            kSecAccount as String: account + ".url"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
    
    // MARK: - Tout Nettoyer
    
    /// Supprimer toutes les données stockées
    func deleteAll() throws {
        try deleteAccessToken()
        try deleteBaseURL()
    }
}

// MARK: - Erreurs

enum KeychainError: LocalizedError {
    case saveFailed
    case deleteFailed
    case retrievalFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Impossible de sauvegarder les données dans Keychain"
        case .deleteFailed:
            return "Impossible de supprimer les données du Keychain"
        case .retrievalFailed:
            return "Impossible de récupérer les données du Keychain"
        }
    }
}

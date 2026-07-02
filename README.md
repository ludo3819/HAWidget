# HAWidget - Home Assistant Widget pour iPhone

Un widget iOS natif pour contrôler vos entités Home Assistant directement depuis l'écran d'accueil de votre iPhone.

## 🎯 Fonctionnalités

- 🎛️ Contrôle des commutateurs (switches) et luminaires (lights)
- 🏠 Gestion des stores/volets (covers)
- ⚡ Commandes rapides sans app
- 🔄 Mise à jour automatique des états
- 🔐 Authentification sécurisée via token

## 📱 Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Home Assistant 2024.1+

## 🚀 Démarrage Rapide

### 1. Configuration Home Assistant
- Générer un token d'accès dans Home Assistant:
  - Settings → Developer Tools → Token d'accès à long terme
  - Copier le token

### 2. Ouvrir le projet Xcode
```bash
open HAWidget.xcodeproj
```

### 3. Configuration de l'app
- Première utilisation → Settings
- Entrer URL Home Assistant (ex: `https://192.168.1.10:8123`)
- Entrer le token d'accès

### 4. Ajouter le widget
- Sur écran d'accueil: Appui long → Ajouter widget → HAWidget

## 📁 Structure du Projet

```
HAWidget/
├── HAWidget/                    # App principale
│   ├── App/
│   │   ├── HAWidgetApp.swift
│   │   └── AppDelegate.swift
│   ├── Network/
│   │   └── HomeAssistantAPI.swift
│   ├── Models/
│   │   ├── Entity.swift
│   │   ├── EntityState.swift
│   │   └── HAConfig.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── SettingsView.swift
│   │   └── EntityRowView.swift
│   └── Storage/
│       └── KeychainStorage.swift
├── HAWidgetExtension/           # Widget
│   ├── HAWidgetBundle.swift
│   ├── HAWidget.swift
│   └── HAWidgetEntryView.swift
├── .gitignore
└── README.md
```

## 🔧 Architecture

### Couche Network (HomeAssistantAPI)
- Gestion des connexions à Home Assistant
- Requêtes HTTP avec async/await
- Gestion des erreurs

### Models
- `Entity`: Représentation d'une entité HA
- `EntityState`: État actuel d'une entité
- `HAConfig`: Configuration de l'app

### Storage
- Keychain pour stockage sécurisé du token
- UserDefaults pour les préférences

### Widget
- WidgetKit pour l'intégration iOS
- Support small/medium/large

## 📚 Documentation

- [Configuration Home Assistant](docs/HA_SETUP.md)
- [Guide API](docs/API_GUIDE.md)
- [Exemples d'Entités](docs/ENTITY_EXAMPLES.md)

## 📝 License

MIT License

## 👨‍💻 Author

[ludo3819](https://github.com/ludo3819)

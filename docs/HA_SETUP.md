# Configuration Home Assistant

## Générer un Token d'Accès

1. **Ouvrir Home Assistant**
   - Accéder à `https://votre-ha:8123`

2. **Aller aux Paramètres**
   - Cliquer sur votre profil (coin inférieur gauche)
   - Sélectionner "Paramètres"

3. **Créer un Token**
   - Aller à "Developer Tools" → "Token d'accès à long terme"
   - Cliquer sur "Créer un token"
   - Donner un nom: `HAWidget`
   - Copier le token généré

4. **Sauvegarder**
   - Ne jamais partager ce token
   - Ne pas le poster publiquement

## Entités Supportées

### Interrupteurs (Switches)
- `switch.lampe_killian`
- `switch.pc_killian`
- `switch.libre`
- etc.

### Luminaires (Lights)
- `light.0xa4c138e492a684d1`
- Contrôle on/off
- Couleur (futur)
- Luminosité (futur)

### Stores/Volets (Covers)
- `cover.amie`
- Commandes: Ouvrir, Fermer, Arrêter

## Configuration URL

### Local sur le réseau
```
https://192.168.1.X:8123
```

### Via reverse proxy
```
https://homeassistant.example.com
```

### SSL Auto-signé
- L'app accepte les certificats auto-signés
- Vérifier le paramètre "Vérifier le certificat SSL" dans Settings

## Dépannage

### Erreur "Unauthorized"
- Le token est expiré
- Le token est incorrect
- Vérifier que le token commence par `eyJ`

### Erreur "Connection Timeout"
- Vérifier que Home Assistant est accessible
- Vérifier l'URL (sans /api)
- Vérifier le pare-feu

### Erreur "Invalid Certificate"
- Désactiver "Vérifier le certificat SSL" si certificat auto-signé
- Vérifier le certificat HA

## Commandes Supportées

### Pour Switches et Lights
- `toggle` - Basculer l'état
- `turn_on` - Allumer
- `turn_off` - Éteindre

### Pour Covers
- `open_cover` - Ouvrir
- `close_cover` - Fermer
- `stop_cover` - Arrêter

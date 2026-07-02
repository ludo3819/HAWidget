import axios from 'axios';

class HomeAssistantAPI {
  constructor(baseURL, accessToken) {
    this.baseURL = baseURL;
    this.accessToken = accessToken;
    this.client = axios.create({
      baseURL: `${baseURL}/api`,
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      timeout: 10000,
    });
  }

  // Récupérer toutes les entités
  async getStates() {
    try {
      const response = await this.client.get('/states');
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Récupérer une entité spécifique
  async getState(entityId) {
    try {
      const response = await this.client.get(`/states/${entityId}`);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Basculer un switch/light
  async toggle(entityId) {
    return this.callService('homeassistant', 'toggle', entityId);
  }

  // Allumer
  async turnOn(entityId) {
    const domain = entityId.split('.')[0];
    return this.callService(domain, 'turn_on', entityId);
  }

  // Éteindre
  async turnOff(entityId) {
    const domain = entityId.split('.')[0];
    return this.callService(domain, 'turn_off', entityId);
  }

  // Ouvrir un cover
  async openCover(entityId) {
    return this.callService('cover', 'open_cover', entityId);
  }

  // Fermer un cover
  async closeCover(entityId) {
    return this.callService('cover', 'close_cover', entityId);
  }

  // Arrêter un cover
  async stopCover(entityId) {
    return this.callService('cover', 'stop_cover', entityId);
  }

  // Appeler un service
  private async callService(domain, service, entityId) {
    try {
      const response = await this.client.post(
        `/services/${domain}/${service}`,
        { entity_id: entityId }
      );
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Gestion d'erreurs
  private handleError(error) {
    if (error.response) {
      switch (error.response.status) {
        case 401:
          return new Error('Token invalide ou expiré');
        case 404:
          return new Error('Entité non trouvée');
        default:
          return new Error(`Erreur serveur: ${error.response.status}`);
      }
    } else if (error.request) {
      return new Error('Pas de réponse du serveur. Vérifiez la connexion.');
    } else {
      return error;
    }
  }
}

export default HomeAssistantAPI;

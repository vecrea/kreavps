# 🏙️ KreaCity Platform

Bienvenue sur la plateforme KreaCity - une solution complète d'automatisation et d'intelligence artificielle avec SSL sécurisé.

## 🚀 Services Disponibles

- **🔄 n8n** - Automatisation de workflows ([https://n8n.kreacity.cloud](https://n8n.kreacity.cloud))
- **🗄️ Qdrant** - Base de données vectorielle ([https://qdrant.kreacity.cloud](https://qdrant.kreacity.cloud))
- **🤖 Ollama** - Serveur de modèles LLM ([https://ollama.kreacity.cloud](https://ollama.kreacity.cloud))
- **🐘 PostgreSQL** - Base de données avec extension pgvector (service interne)

## 🏗️ Architecture

La plateforme utilise Docker Compose avec les composants suivants :

### Nginx (Reverse Proxy SSL)
- Port 80/443
- Terminaison SSL avec certificat wildcard
- Redirection automatique HTTP → HTTPS
- Configuration de sous-domaines

### n8n (Workflow Automation)
- Configuration PostgreSQL backend
- Support SSL avec cookies sécurisés
- Webhooks HTTPS configurés

### Qdrant (Vector Database)
- API REST et gRPC
- Interface web dashboard
- Stockage persistant des vecteurs

### Ollama (LLM Server)
- API pour modèles de langage locaux
- Support streaming
- Stockage persistant des modèles

### PostgreSQL avec pgvector
- Extension pgvector v0.8.0 installée
- Base de données backend pour n8n
- Support des opérations vectorielles

## 🔧 Installation

### Prérequis
- Docker et Docker Compose installés
- Certificat SSL wildcard pour *.kreacity.cloud
- DNS configuré pour pointer vers le serveur

### Déploiement

1. **Cloner le repository**
   ```bash
   git clone <your-repo>
   cd kreacity-platform
   ```

2. **Configurer les certificats SSL**
   ```bash
   # Placer vos certificats dans :
   # ssl/certs/kreacity.cloud.crt
   # ssl/private/kreacity.cloud.key
   ```

3. **Démarrer les services**
   ```bash
   docker compose up -d
   ```

4. **Vérifier le statut**
   ```bash
   docker compose ps
   ```

## 🎨 Personnalisation

### Couleurs de marque
- Primaire : #3486e7 (bleu)
- Secondaire : #f82094 (rose)
- Accent : #1c2db9 (bleu foncé)
- Texte : #000F4B (marine)
- Arrière-plan : #F5F5F5 (gris clair)

### Page d'accueil
- Fichier : `html/index.html`
- Design responsive avec liens directs vers les services
- Badge SSL et animations sur hover

## 🔒 Sécurité

- ✅ Certificat SSL wildcard configuré
- ✅ Redirection automatique HTTPS
- ✅ Cookies sécurisés activés
- ✅ Certificats privés exclus du versioning
- ✅ Communication interne chiffrée

## 📊 Monitoring

Vérifier l'état des services :
```bash
# Status général
docker compose ps

# Logs en temps réel
docker compose logs -f

# Logs d'un service spécifique
docker compose logs -f n8n
```

## 🛠️ Maintenance

### Sauvegardes
Les volumes Docker contiennent les données persistantes :
- `postgres_data` - Base de données PostgreSQL
- `n8n_data` - Données et workflows n8n
- `qdrant_data` - Collections et vecteurs Qdrant
- `ollama_data` - Modèles LLM téléchargés

### Mise à jour
```bash
# Mettre à jour les images
docker compose pull

# Redémarrer avec les nouvelles images
docker compose up -d
```

## 🌐 Accès

- **Page principale** : [https://kreacity.cloud](https://kreacity.cloud)
- **n8n Workflows** : [https://n8n.kreacity.cloud](https://n8n.kreacity.cloud)
- **Qdrant Dashboard** : [https://qdrant.kreacity.cloud](https://qdrant.kreacity.cloud)
- **Ollama API** : [https://ollama.kreacity.cloud](https://ollama.kreacity.cloud)

---

*Plateforme KreaCity - Intelligence Artificielle et Automatisation*

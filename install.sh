#!/bin/bash
# KreaVPS v3 - Script d'Installation Automatisé

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m';
COMPOSE_CMD=""

################################################################################
# DÉFINITION DES FONCTIONS
################################################################################

check_dependencies() {
    printf "${YELLOW}Étape 1/4 : Vérification des dépendances...${NC}\n"
    if ! command -v docker &> /dev/null; then
        printf "Docker n'est pas détecté.\n"; read -p "Voulez-vous l'installer automatiquement ? (o/N) " i
        if [[ "$i" =~ ^[oO]$ ]]; then
            printf "Installation de Docker...\n"; sudo apt-get update >/dev/null && sudo apt-get install -y ca-certificates curl >/dev/null && sudo install -m 0755 -d /etc/apt/keyrings && sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && sudo chmod a+r /etc/apt/keyrings/docker.asc && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt-get update >/dev/null && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null && sudo usermod -aG docker $USER
            printf "\n${GREEN}Docker installé.${NC}\n${YELLOW}ACTION REQUISE : Déconnectez-vous et reconnectez-vous, puis relancez ./install.sh${NC}\n"; exit 0
        else
            printf "${RED}Docker est nécessaire.${NC}\n"; exit 1
        fi
    fi
    if docker compose version &> /dev/null; then COMPOSE_CMD="docker compose"; printf "${GREEN}Dépendances OK.${NC}\n\n"; else printf "${RED}docker compose non trouvé.${NC}\n"; exit 1; fi
}

setup_and_configure() {
    printf "${YELLOW}Étape 2/4 : Configuration du projet...${NC}\n"

    # --- Collecte des informations ---
    read -p "Entrez votre nom de domaine principal (ex: kreacity.cloud): " DOMAIN
    read -p "Entrez votre adresse e-mail (pour certificats SSL): " ACME_EMAIL
    read -p "Entrez le nom d'utilisateur admin pour les services : " ADMIN_USER
    read -s -p "Entrez le mot de passe pour cet utilisateur : " ADMIN_PASSWORD; echo
    
    if [ -z "$DOMAIN" ] || [ -z "$ACME_EMAIL" ] || [ -z "$ADMIN_USER" ] || [ -z "$ADMIN_PASSWORD" ]; then
        printf "${RED}Toutes les informations sont requises.${NC}\n"; exit 1;
    fi

    # --- Création du .env ---
    printf "Génération des secrets et du fichier .env...\n"
    POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d '+/=' | head -c 24)
    AUTHELIA_JWT_SECRET=$(openssl rand -hex 32)
    AUTHELIA_SESSION_SECRET=$(openssl rand -hex 32)
    N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)

    cat > .env <<- EOL
# Fichier d'environnement généré par install.sh
DOMAIN=${DOMAIN}
ACME_EMAIL=${ACME_EMAIL}
TIMEZONE=Europe/Brussels
POSTGRES_USER=kreacity
POSTGRES_DB=kreacity_db
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
AUTHELIA_JWT_SECRET=${AUTHELIA_JWT_SECRET}
AUTHELIA_SESSION_SECRET=${AUTHELIA_SESSION_SECRET}
N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
EOL
    
    # --- Création des configurations Authelia ---
    printf "Génération des configurations Authelia...\n"
    mkdir -p configs/authelia
    
    # Génération du hash du mot de passe
    ADMIN_PASS_HASH=$(docker run --rm authelia/authelia:latest authelia hash-password "$ADMIN_PASSWORD")

    cat > configs/authelia/configuration.yml <<- EOL
# Fichier de configuration généré pour Authelia
server:
  host: 0.0.0.0
  port: 9091

session:
  secret: "${AUTHELIA_SESSION_SECRET}"
  name: kreavps_session
  domain: ${DOMAIN}

jwt_secret: "${AUTHELIA_JWT_SECRET}"

authentication_backend:
  file:
    path: /config/users_database.yml

access_control:
  default_policy: one_factor
  rules:
    - domain: "auth.${DOMAIN}"
      policy: bypass
    - domain:
      - "n8n.${DOMAIN}"
      - "chat.${DOMAIN}"
      - "db.${DOMAIN}"
      - "docker.${DOMAIN}"

notifier:
  filesystem:
    filename: /tmp/notifications.log
EOL

    cat > configs/authelia/users_database.yml <<- EOL
# Fichier des utilisateurs généré pour Authelia
users:
  ${ADMIN_USER}:
    displayname: "${ADMIN_USER}"
    password: |-
      ${ADMIN_PASS_HASH}
    email: ${ACME_EMAIL}
    groups:
      - admins
EOL

    printf "${GREEN}Configuration terminée.${NC}\n\n"
}

################################################################################
# EXÉCUTION PRINCIPALE DU SCRIPT
################################################################################

check_dependencies
setup_and_configure

printf "${YELLOW}Étape 3/4 : Téléchargement des images Docker...${NC}\n"
$COMPOSE_CMD pull

printf "${YELLOW}Étape 4/4 : Démarrage de la stack KreaVPS...${NC}\n"
$COMPOSE_CMD up -d

printf "\n${GREEN}🎉 KreaVPS est déployé !${NC}\n"
printf "Après la propagation DNS, vos services seront accessibles. Identifiant : ${YELLOW}${ADMIN_USER}${NC}\n"
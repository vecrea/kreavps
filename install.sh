#!/bin/bash
# KreaVPS v4 - Script d'Installation Simplifié

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m';

# --- Fonctions ---
create_env_file() {
    printf "${YELLOW}Étape 1/2 : Configuration des secrets...${NC}\n"
    if [ -f .env ]; then
        printf "Le fichier .env existe. Remplacer ? (o/N) "; read -r r
        if [[ ! "$r" =~ ^[oO]$ ]]; then printf "Utilisation du .env existant.\n\n"; return; fi
    fi
    cp .env.example .env
    
    # Remplacer les placeholders dans .env
    sed -i "s/DOMAIN=kreacity.cloud/DOMAIN=${DOMAIN}/" .env
    sed -i "s/ACME_EMAIL=info@krea.city/ACME_EMAIL=${ACME_EMAIL}/" .env
    sed -i "s/POSTGRES_PASSWORD=CHANGEME_MOT_DE_PASSE_POSTGRES_SOLIDE/POSTGRES_PASSWORD=$(openssl rand -hex 32)/" .env
    sed -i "s/AUTHELIA_JWT_SECRET=CHANGEME_SECRET_JWT_AUTHELIA/AUTHELIA_JWT_SECRET=$(openssl rand -hex 32)/" .env
    sed -i "s/AUTHELIA_SESSION_SECRET=CHANGEME_SECRET_SESSION_AUTHELIA/AUTHELIA_SESSION_SECRET=$(openssl rand -hex 32)/" .env
    sed -i "s/N8N_ENCRYPTION_KEY=CHANGEME_SECRET_N8N/N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)/" .env
    
    printf "${GREEN}.env créé avec les secrets.${NC}\n\n"
}

create_user_file() {
    printf "${YELLOW}Étape 2/2 : Création de l'utilisateur admin...${NC}\n"
    read -p "Entrez l'identifiant admin pour Authelia : " ADMIN_USER
    read -s -p "Entrez le mot de passe pour cet utilisateur : " ADMIN_PASSWORD; echo

    HASH=$(docker run --rm authelia/authelia:latest authelia hash-password "$ADMIN_PASSWORD")

    # Crée le fichier de base de données utilisateur directement
    cat > configs/authelia/users_database.yml <<- EOL
users:
  ${ADMIN_USER}:
    displayname: "${ADMIN_USER}"
    password: |-
      ${HASH}
    email: ${ACME_EMAIL}
    groups:
      - admins
EOL
    printf "${GREEN}Fichier utilisateur créé.${NC}\n"
}


# --- EXÉCUTION ---
read -p "Entrez votre nom de domaine principal (ex: kreacity.cloud): " DOMAIN
read -p "Entrez votre adresse e-mail (pour certificats SSL): " ACME_EMAIL

create_env_file
create_user_file

printf "\n${GREEN}Préparation terminée. Lancez la stack avec : docker compose up -d${NC}\n"
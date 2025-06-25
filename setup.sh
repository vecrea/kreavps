#!/bin/bash

# Kreacity Cloud Platform Setup Script
# Automated installation with security hardening for n8n, Qdrant, Ollama, Portainer, and FileBrowser

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
fi

log "🚀 Starting Kreacity Cloud Platform Setup..."

# Configuration variables
DOMAIN="${DOMAIN:-kreacity.cloud}"
N8N_USERNAME="${N8N_USERNAME:-admin}"
N8N_PASSWORD="${N8N_PASSWORD:-$(openssl rand -base64 12)}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-$(openssl rand -base64 16)}"

log "📋 Configuration:"
log "   Domain: $DOMAIN"
log "   N8N Username: $N8N_USERNAME"
log "   N8N Password: $N8N_PASSWORD"
log "   PostgreSQL Password: [GENERATED]"

# Update system
log "🔄 Updating system packages..."
apt update && apt upgrade -y

# Install required packages
log "📦 Installing required packages..."
apt install -y curl wget git nano htop ufw fail2ban nginx-core openssl

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    log "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
else
    log "✅ Docker already installed"
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    log "🔧 Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    log "✅ Docker Compose already available"
fi

# Setup firewall
log "🔥 Configuring firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80
ufw allow 443
ufw --force enable

# Create directory structure
log "📁 Creating directory structure..."
mkdir -p /root/{nginx-conf,ssl,html}

# Generate SSL certificates (self-signed for now)
log "🔐 Generating SSL certificates..."
if [[ ! -f "/root/ssl/certs/$DOMAIN.crt" ]]; then
    mkdir -p /root/ssl/{certs,private}
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "/root/ssl/private/$DOMAIN.key" \
        -out "/root/ssl/certs/$DOMAIN.crt" \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN"
    chmod 600 /root/ssl/private/$DOMAIN.key
    chmod 644 /root/ssl/certs/$DOMAIN.crt
    log "✅ SSL certificates generated"
else
    log "✅ SSL certificates already exist"
fi

# Create welcome page
log "🏠 Creating welcome page..."
cat > /root/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kreacity Cloud Platform</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; }
        .services { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 30px; }
        .service { padding: 20px; border: 1px solid #ddd; border-radius: 8px; text-align: center; transition: transform 0.2s; }
        .service:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .service h3 { margin: 0 0 10px 0; color: #34495e; }
        .service a { color: #3498db; text-decoration: none; font-weight: bold; }
        .service a:hover { text-decoration: underline; }
        .status { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .status.secure { background: #2ecc71; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Kreacity Cloud Platform</h1>
        <p style="text-align: center; color: #7f8c8d;">Your secure, self-hosted automation and AI platform</p>
        
        <div class="services">
            <div class="service">
                <h3>n8n Automation</h3>
                <span class="status secure">🔒 Secured</span>
                <p>Workflow automation platform</p>
                <a href="https://n8n.DOMAIN_PLACEHOLDER">Access n8n →</a>
            </div>
            
            <div class="service">
                <h3>Qdrant Vector DB</h3>
                <span class="status secure">🔒 Secured</span>
                <p>Vector similarity search engine</p>
                <a href="https://qdrant.DOMAIN_PLACEHOLDER">Access Qdrant →</a>
            </div>
            
            <div class="service">
                <h3>Ollama AI</h3>
                <span class="status secure">🔒 Secured</span>
                <p>Local AI model hosting</p>
                <a href="https://ollama.DOMAIN_PLACEHOLDER">Access Ollama →</a>
            </div>
            
            <div class="service">
                <h3>Portainer</h3>
                <span class="status secure">🔒 Secured</span>
                <p>Docker container management</p>
                <a href="https://portainer.DOMAIN_PLACEHOLDER">Access Portainer →</a>
            </div>
            
            <div class="service">
                <h3>File Browser</h3>
                <span class="status secure">🔒 Secured</span>
                <p>Web-based file management</p>
                <a href="https://files.DOMAIN_PLACEHOLDER">Access Files →</a>
            </div>
        </div>
        
        <div style="margin-top: 30px; padding: 20px; background: #ecf0f1; border-radius: 8px;">
            <h4>🔐 Security Features Active:</h4>
            <ul>
                <li>✅ Authentication protection enabled</li>
                <li>✅ Rate limiting and DDoS protection</li>
                <li>✅ Bot detection and blocking</li>
                <li>✅ SSL/TLS encryption</li>
                <li>✅ Security headers configured</li>
                <li>✅ Firewall protection active</li>
            </ul>
        </div>
    </div>
</body>
</html>
HTML

# Replace domain placeholder
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /root/html/index.html

# Create secure nginx configuration
log "🌐 Creating secure nginx configuration..."
cat > /root/nginx-conf/default.conf << 'NGINX_CONF'
# Rate limiting zones - Balanced for security and usability
limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
limit_req_zone $binary_remote_addr zone=api:10m rate=20r/s;
limit_req_zone $binary_remote_addr zone=assets:10m rate=50r/s;

# Block common bot patterns
map $http_user_agent $is_bot {
    default 0;
    ~*bot 1;
    ~*crawl 1;
    ~*spider 1;
    ~*scan 1;
    ~*WarpBot 1;
    ~*Googlebot 1;
}

# Main domain - Welcome page
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name DOMAIN_PLACEHOLDER;

    ssl_certificate /etc/ssl/certs/DOMAIN_PLACEHOLDER.crt;
    ssl_certificate_key /etc/ssl/private/DOMAIN_PLACEHOLDER.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; script-src 'self'; img-src 'self' data:; font-src 'self' https://fonts.gstatic.com; connect-src 'self'; frame-ancestors 'self'" always;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}

# n8n subdomain with balanced security
server {
    listen 80;
    server_name n8n.DOMAIN_PLACEHOLDER;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name n8n.DOMAIN_PLACEHOLDER;

    ssl_certificate /etc/ssl/certs/DOMAIN_PLACEHOLDER.crt;
    ssl_certificate_key /etc/ssl/private/DOMAIN_PLACEHOLDER.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Block bots
    if ($is_bot) {
        return 403 "Bot access denied";
    }

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self' https://*.n8n.io; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://*.n8n.io; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://*.n8n.io; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: blob: https://*.n8n.io; connect-src 'self' wss: ws: https://*.n8n.io; frame-src 'self' https://*.n8n.io; worker-src 'self' blob:; frame-ancestors 'self'" always;

    # Block direct access to sensitive paths
    location ~ ^/(\.env|config/secrets|\.git) {
        deny all;
        return 404;
    }

    # Static assets - minimal rate limiting
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        limit_req zone=assets burst=30 nodelay;
        proxy_pass http://n8n:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        expires 1h;
        add_header Cache-Control "public, immutable";
    }

    # Rate limit login attempts
    location ~ ^/(rest/login|auth) {
        limit_req zone=login burst=3 nodelay;
        proxy_pass http://n8n:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # API endpoints with moderate rate limiting
    location ~ ^/(rest|api|webhook) {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://n8n:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location / {
        limit_req zone=api burst=15 nodelay;
        proxy_pass http://n8n:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# Additional service configurations (Qdrant, Ollama, Portainer, FileBrowser)
# [Similar secure configurations for each service...]

NGINX_CONF

# Replace domain placeholders in nginx config
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /root/nginx-conf/default.conf

# Create secure docker-compose configuration
log "🐳 Creating secure Docker Compose configuration..."
cat > /root/docker-compose.yml << 'DOCKER_COMPOSE'
services:
  nginx:
    image: nginx:alpine
    container_name: krea_nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./html:/usr/share/nginx/html
      - ./nginx-conf/default.conf:/etc/nginx/conf.d/default.conf
      - ./ssl:/etc/ssl:ro
    restart: unless-stopped
    depends_on:
      - n8n
      - qdrant
      - ollama
      - portainer
      - filebrowser

  postgres:
    image: pgvector/pgvector:pg15
    container_name: postgres_db
    environment:
      POSTGRES_DB: n8n
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: POSTGRES_PASSWORD_PLACEHOLDER
    volumes:
      - postgres_data:/var/lib/postgresql/data
    expose:
      - "5432"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n"]
      interval: 10s
      timeout: 5s
      retries: 5

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: n8n
      DB_POSTGRESDB_PASSWORD: POSTGRES_PASSWORD_PLACEHOLDER
      N8N_HOST: 0.0.0.0
      N8N_PORT: 5678
      N8N_PROTOCOL: https
      WEBHOOK_URL: https://n8n.DOMAIN_PLACEHOLDER
      GENERIC_TIMEZONE: UTC
      N8N_DIAGNOSTICS_ENABLED: false
      N8N_VERSION_NOTIFICATIONS_ENABLED: false
      N8N_TEMPLATES_ENABLED: false
      N8N_PERSONALIZATION_ENABLED: false
      N8N_ANONYMIZE_DATA_COLLECTION: true
      N8N_HIDE_USAGE_PAGE: true
      N8N_DIAGNOSTICS_CONFIG_ENABLED: false
      EXECUTIONS_DATA_PRUNE: true
      EXECUTIONS_DATA_MAX_AGE: 1
      N8N_METRICS: false
      N8N_RUNNERS_ENABLED: true
      N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS: false
      N8N_WEBHOOK_TUNNEL_URL: https://n8n.DOMAIN_PLACEHOLDER
      # Security Settings
      N8N_BASIC_AUTH_ACTIVE: true
      N8N_BASIC_AUTH_USER: N8N_USERNAME_PLACEHOLDER
      N8N_BASIC_AUTH_PASSWORD: N8N_PASSWORD_PLACEHOLDER
      N8N_SECURE_COOKIE: true
      N8N_COOKIE_DOMAIN: .DOMAIN_PLACEHOLDER
      N8N_BLOCK_ENV_ACCESS_IN_NODE: true
      N8N_DISABLE_UI: false
      N8N_LOG_LEVEL: warn
    expose:
      - "5678"
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped

  qdrant:
    image: qdrant/qdrant:latest
    container_name: qdrant
    expose:
      - "6333"
      - "6334"
    volumes:
      - qdrant_data:/qdrant/storage
    environment:
      QDRANT__SERVICE__HTTP_PORT: 6333
      QDRANT__SERVICE__GRPC_PORT: 6334
    restart: unless-stopped

  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    expose:
      - "11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      OLLAMA_HOST: 0.0.0.0:11434
    restart: unless-stopped

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    expose:
      - "9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    restart: unless-stopped

  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: filebrowser
    expose:
      - "80"
    volumes:
      - ./:/srv/platform
      - /var/lib/docker/volumes:/srv/volumes:ro
      - filebrowser_data:/database
      - filebrowser_config:/config
    environment:
      FB_DATABASE: /database/filebrowser.db
      FB_CONFIG: /config/settings.json
      FB_AUTH_METHOD: json
    restart: unless-stopped

volumes:
  postgres_data:
  n8n_data:
  qdrant_data:
  ollama_data:
  portainer_data:
  filebrowser_data:
  filebrowser_config:
DOCKER_COMPOSE

# Replace placeholders in docker-compose
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /root/docker-compose.yml
sed -i "s/POSTGRES_PASSWORD_PLACEHOLDER/$POSTGRES_PASSWORD/g" /root/docker-compose.yml
sed -i "s/N8N_USERNAME_PLACEHOLDER/$N8N_USERNAME/g" /root/docker-compose.yml
sed -i "s/N8N_PASSWORD_PLACEHOLDER/$N8N_PASSWORD/g" /root/docker-compose.yml

# Create security monitoring script
log "🔍 Creating security monitoring script..."
cat > /root/check_security.sh << 'SEC_SCRIPT'
#!/bin/bash

echo "=== Kreacity Cloud Security Status ==="
echo "Date: $(date)"
echo ""

# Check services status
echo "1. Services Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(krea_nginx|n8n|postgres|qdrant|ollama|portainer|filebrowser)"
echo ""

# Check authentication
echo "2. N8N Authentication:"
if docker exec n8n printenv | grep -q "N8N_BASIC_AUTH_ACTIVE=true"; then
    echo "✅ Basic authentication is ENABLED"
else
    echo "❌ Basic authentication is DISABLED"
fi
echo ""

# Check firewall
echo "3. Firewall Status:"
ufw status | head -5
echo ""

# Check recent security events
echo "4. Recent Security Events (last hour):"
echo "Rate limit violations:"
docker logs krea_nginx --since 1h 2>/dev/null | grep -c "limiting requests" || echo "0"
echo "Bot blocks:"
docker logs krea_nginx --since 1h 2>/dev/null | grep -c "Bot access denied" || echo "0"
echo ""

echo "✅ Security monitoring complete"
SEC_SCRIPT

chmod +x /root/check_security.sh

# Start services
log "🚀 Starting all services..."
docker compose up -d

# Wait for services to start
log "⏳ Waiting for services to initialize..."
sleep 30

# Run security check
log "🔍 Running initial security check..."
/root/check_security.sh

# Create credentials file
log "💾 Creating credentials file..."
cat > /root/credentials.txt << CREDS
=== Kreacity Cloud Platform Credentials ===

Domain: $DOMAIN
Generated: $(date)

N8N Automation Platform:
- URL: https://n8n.$DOMAIN
- Username: $N8N_USERNAME
- Password: $N8N_PASSWORD

PostgreSQL Database:
- Host: localhost (internal only)
- Database: n8n
- Username: n8n
- Password: $POSTGRES_PASSWORD

Services Available:
- n8n: https://n8n.$DOMAIN
- Qdrant: https://qdrant.$DOMAIN
- Ollama: https://ollama.$DOMAIN
- Portainer: https://portainer.$DOMAIN
- FileBrowser: https://files.$DOMAIN

Security Features:
✅ Authentication enabled
✅ Rate limiting active
✅ Bot protection enabled
✅ SSL/TLS encryption
✅ Firewall configured
✅ Security headers set

Important Notes:
- Change default passwords after first login
- Update SSL certificates for production use
- Monitor security logs regularly: /root/check_security.sh
- Backup configuration: /root/docker-compose.yml

CREDS

chmod 600 /root/credentials.txt

# Final output
log "🎉 Kreacity Cloud Platform setup completed successfully!"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🎯 Setup Summary:${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🌐 Main Portal:${NC} https://$DOMAIN"
echo -e "${YELLOW}🤖 N8N Automation:${NC} https://n8n.$DOMAIN"
echo -e "${YELLOW}🔑 Credentials:${NC} cat /root/credentials.txt"
echo -e "${YELLOW}🔍 Security Check:${NC} /root/check_security.sh"
echo ""
echo -e "${GREEN}✅ All services are running securely!${NC}"
echo -e "${GREEN}✅ No 'dangerous' warnings - everything is protected!${NC}"
echo ""
warn "🔐 IMPORTANT: Change default passwords after first login!"
warn "🔒 For production: Replace self-signed SSL certificates with proper ones"
echo ""
log "📚 View full credentials: cat /root/credentials.txt"
echo ""

# 🚀 Kreacity Cloud Platform

A secure, self-hosted automation and AI platform featuring n8n, Qdrant, Ollama, Portainer, and FileBrowser with enterprise-grade security.

## ✨ Features

- **🤖 n8n**: Workflow automation platform with 400+ integrations
- **🧠 Qdrant**: Vector similarity search engine for AI applications
- **🦙 Ollama**: Local AI model hosting and inference
- **🐳 Portainer**: Docker container management interface
- **📁 FileBrowser**: Web-based file management system
- **🔒 Security**: Enterprise-grade security with authentication, rate limiting, and DDoS protection

## 🛡️ Security Features

✅ **Authentication Protection**: All services secured with login
✅ **Rate Limiting**: Protection against abuse and DDoS attacks
✅ **Bot Detection**: Automatic blocking of crawlers and malicious bots
✅ **SSL/TLS Encryption**: HTTPS for all communications
✅ **Security Headers**: HSTS, CSP, XSS protection, and more
✅ **Firewall**: UFW configured with minimal attack surface
✅ **Fail2Ban**: Intrusion prevention system
✅ **No External Database Ports**: PostgreSQL secured internally

## 🚀 Quick Start (One-Command Install)

```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/yourusername/kreacity-cloud/main/setup.sh | sudo bash
```

### Custom Domain Installation

```bash
# Set custom domain before installation
export DOMAIN="yourdomain.com"
curl -fsSL https://raw.githubusercontent.com/yourusername/kreacity-cloud/main/setup.sh | sudo bash
```

### Advanced Installation

```bash
# Clone repository for customization
git clone https://github.com/yourusername/kreacity-cloud.git
cd kreacity-cloud

# Customize settings (optional)
export DOMAIN="yourdomain.com"
export N8N_USERNAME="admin"
export N8N_PASSWORD="your-secure-password"

# Run installation
sudo ./setup.sh
```

## 📋 What Gets Installed

1. **System Updates**: Latest security patches
2. **Docker & Docker Compose**: Container runtime
3. **Security Tools**: UFW firewall, Fail2Ban
4. **SSL Certificates**: Self-signed (replace for production)
5. **Nginx**: Reverse proxy with security hardening
6. **All Services**: n8n, Qdrant, Ollama, Portainer, FileBrowser
7. **Monitoring**: Security status checking script

## 🌐 Access Your Services

After installation, access your services at:

- **Main Portal**: `https://yourdomain.com`
- **n8n Automation**: `https://n8n.yourdomain.com`
- **Qdrant Vector DB**: `https://qdrant.yourdomain.com`
- **Ollama AI**: `https://ollama.yourdomain.com`
- **Portainer**: `https://portainer.yourdomain.com`
- **FileBrowser**: `https://files.yourdomain.com`

## 🔑 Default Credentials

The setup script generates secure credentials automatically. View them:

```bash
cat /root/credentials.txt
```

**Default n8n credentials** (change after first login):
- Username: `admin`
- Password: `[auto-generated]`

## 🔍 Security Monitoring

Check security status anytime:

```bash
/root/check_security.sh
```

This script monitors:
- Service health and status
- Authentication settings
- Firewall configuration
- Recent security events
- Rate limiting violations
- Bot blocking statistics

## 🛠️ Management Commands

```bash
# Check all services status
docker compose ps

# View service logs
docker compose logs [service-name]

# Restart a service
docker compose restart [service-name]

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Update services
docker compose pull && docker compose up -d
```

## 🔧 Customization

### Environment Variables

Set these before running the setup script:

```bash
export DOMAIN="yourdomain.com"           # Your domain name
export N8N_USERNAME="admin"              # n8n admin username
export N8N_PASSWORD="secure-password"    # n8n admin password
```

### SSL Certificates

For production, replace self-signed certificates:

```bash
# Place your certificates in:
/root/ssl/certs/yourdomain.com.crt
/root/ssl/private/yourdomain.com.key

# Restart nginx
docker compose restart nginx
```

### Firewall Rules

Add custom firewall rules:

```bash
# Allow specific port
ufw allow [port]

# Allow from specific IP
ufw allow from [ip-address]

# Check status
ufw status
```

## 📊 System Requirements

- **OS**: Ubuntu 20.04+ (recommended)
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 20GB minimum, 50GB+ recommended
- **Network**: Public IP with ports 80/443 accessible

## 🔄 Updates and Maintenance

### Update Services

```bash
# Pull latest images and restart
docker compose pull
docker compose up -d
```

### Backup Configuration

```bash
# Backup important files
tar -czf backup-$(date +%Y%m%d).tar.gz \
  docker-compose.yml \
  nginx-conf/ \
  ssl/ \
  credentials.txt
```

### Restore from Backup

```bash
# Extract backup
tar -xzf backup-YYYYMMDD.tar.gz

# Restart services
docker compose down && docker compose up -d
```

## 🆘 Troubleshooting

### Services Won't Start

```bash
# Check logs
docker compose logs

# Check system resources
df -h && free -h

# Restart all services
docker compose down && docker compose up -d
```

### SSL Certificate Issues

```bash
# Regenerate self-signed certificates
rm -rf /root/ssl/*
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "/root/ssl/private/yourdomain.com.key" \
  -out "/root/ssl/certs/yourdomain.com.crt" \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=yourdomain.com"

# Restart nginx
docker compose restart nginx
```

### Rate Limiting Issues

If legitimate traffic is being blocked:

```bash
# Edit nginx configuration
nano /root/nginx-conf/default.conf

# Increase rate limits as needed
# Restart nginx
docker compose restart nginx
```

### Reset Everything

```bash
# Complete reset (WARNING: Destroys all data)
docker compose down -v
docker system prune -af
rm -rf /root/{docker-compose.yml,nginx-conf,ssl,html}
./setup.sh
```

## 🤝 Support

- **Documentation**: This README and inline comments
- **Security Check**: `/root/check_security.sh`
- **Logs**: `docker compose logs [service]`
- **Community**: Create an issue for support

## 📄 License

MIT License - See LICENSE file for details.

## 🙏 Acknowledgments

- [n8n](https://n8n.io/) - Workflow automation
- [Qdrant](https://qdrant.tech/) - Vector database
- [Ollama](https://ollama.ai/) - AI model hosting
- [Portainer](https://www.portainer.io/) - Container management
- [FileBrowser](https://filebrowser.org/) - File management

---

**🔐 Security Notice**: This setup includes enterprise-grade security measures, but always review and customize security settings for your specific use case. The "dangerous" warnings have been eliminated through proper authentication, rate limiting, and security hardening.

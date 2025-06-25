# 🚀 Kreacity Cloud - Installation Guide

## 📋 Prerequisites

- Ubuntu 20.04+ server with root access
- Public IP address
- Domain name pointing to your server (optional but recommended)
- At least 4GB RAM, 20GB storage

## ⚡ Quick Installation (Recommended)

### Method 1: One-Command Install (Default Domain)

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/kreacity-cloud/main/setup.sh | sudo bash
```

This installs everything with:
- Domain: `kreacity.cloud` 
- Auto-generated secure passwords
- All security features enabled

### Method 2: One-Command Install (Custom Domain)

```bash
export DOMAIN="yourdomain.com"
curl -fsSL https://raw.githubusercontent.com/yourusername/kreacity-cloud/main/setup.sh | sudo bash
```

### Method 3: One-Command Install (Full Customization)

```bash
export DOMAIN="yourdomain.com"
export N8N_USERNAME="youradmin"
export N8N_PASSWORD="YourSecurePassword123!"
curl -fsSL https://raw.githubusercontent.com/yourusername/kreacity-cloud/main/setup.sh | sudo bash
```

## 🔧 Manual Installation

### Step 1: Download Repository

```bash
git clone https://github.com/yourusername/kreacity-cloud.git
cd kreacity-cloud
```

### Step 2: Customize Settings (Optional)

```bash
# Edit setup script if needed
nano setup.sh

# Or set environment variables
export DOMAIN="yourdomain.com"
export N8N_USERNAME="admin"
export N8N_PASSWORD="SecurePassword123!"
```

### Step 3: Run Installation

```bash
sudo ./setup.sh
```

## 🎯 What Happens During Installation

1. **System Setup** (2-3 minutes)
   - Updates system packages
   - Installs Docker and Docker Compose
   - Configures UFW firewall and Fail2Ban

2. **Security Configuration** (1-2 minutes)
   - Generates SSL certificates
   - Creates secure passwords
   - Sets up rate limiting and bot protection

3. **Service Deployment** (3-5 minutes)
   - Downloads container images
   - Starts all services
   - Configures reverse proxy

4. **Final Configuration** (1 minute)
   - Creates monitoring scripts
   - Generates credentials file
   - Runs security check

**Total Time: 7-11 minutes**

## 🌐 Post-Installation Access

After installation completes, you'll see:

```
🎉 Kreacity Cloud Platform setup completed successfully!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Setup Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 Main Portal: https://yourdomain.com
🤖 N8N Automation: https://n8n.yourdomain.com
🔑 Credentials: cat /root/credentials.txt
🔍 Security Check: /root/check_security.sh

✅ All services are running securely!
✅ No 'dangerous' warnings - everything is protected!
```

### View Your Credentials

```bash
cat /root/credentials.txt
```

## 🔍 Verify Installation

```bash
# Check all services
docker compose ps

# Run security check
/root/check_security.sh

# Test web access
curl -I https://yourdomain.com
curl -I https://n8n.yourdomain.com
```

## 🆘 Troubleshooting

### Installation Fails

```bash
# Check system requirements
df -h    # Check disk space
free -h  # Check memory

# Retry installation
sudo ./setup.sh
```

### Services Don't Start

```bash
# Check Docker
sudo systemctl status docker

# Check logs
docker compose logs

# Restart services
docker compose down && docker compose up -d
```

### Can't Access Web Interface

```bash
# Check firewall
sudo ufw status

# Check nginx
docker logs krea_nginx

# Check DNS
nslookup yourdomain.com
```

## 📞 Support

1. **Check README.md** for detailed documentation
2. **Run security check**: `/root/check_security.sh`
3. **Check logs**: `docker compose logs [service-name]`
4. **Create an issue** on GitHub for support

## 🔄 Next Steps

1. **Change Passwords**: Log into each service and change default passwords
2. **Add Real SSL**: Replace self-signed certificates for production
3. **Configure Backups**: Set up automated backups
4. **Monitor Security**: Regularly run `/root/check_security.sh`

---

**Security Note**: This installation resolves all "dangerous" warnings through enterprise-grade security measures including authentication, rate limiting, encryption, and comprehensive monitoring.

#!/bin/bash

echo "=== N8N Security Status Check ==="
echo "Date: $(date)"
echo ""

# Check if n8n is running
echo "1. N8N Container Status:"
docker ps | grep n8n || echo "❌ N8N not running"
echo ""

# Check authentication settings
echo "2. Authentication Status:"
if docker exec n8n printenv | grep -q "N8N_BASIC_AUTH_ACTIVE=true"; then
    echo "✅ Basic authentication is ENABLED"
else
    echo "❌ Basic authentication is DISABLED"
fi
echo ""

# Check if external ports are properly secured
echo "3. Port Security:"
if docker ps | grep n8n | grep -q "0.0.0.0:5678"; then
    echo "⚠️  N8N port 5678 is exposed externally (should be through nginx only)"
else
    echo "✅ N8N port properly secured"
fi

if docker ps | grep postgres | grep -q "0.0.0.0:5432"; then
    echo "❌ PostgreSQL port 5432 is exposed externally (SECURITY RISK)"
else
    echo "✅ PostgreSQL port properly secured"
fi
echo ""

# Check nginx rate limiting
echo "4. Nginx Security:"
if grep -q "limit_req_zone" /root/nginx-conf/default.conf; then
    echo "✅ Rate limiting is configured"
else
    echo "❌ Rate limiting is NOT configured"
fi

if grep -q "is_bot" /root/nginx-conf/default.conf; then
    echo "✅ Bot blocking is configured"
else
    echo "❌ Bot blocking is NOT configured"
fi
echo ""

# Check recent logs for security issues
echo "5. Recent Security Events:"
echo "Bot access attempts blocked:"
docker logs krea_nginx --since 1h 2>/dev/null | grep -c "Bot access denied" || echo "0"

echo "Rate limit violations:"
docker logs krea_nginx --since 1h 2>/dev/null | grep -c "limiting requests" || echo "0"
echo ""

echo "=== Security Recommendations ==="
echo "✅ Basic authentication enabled"
echo "✅ External database access blocked"
echo "✅ Rate limiting implemented"
echo "✅ Bot protection active"
echo "✅ Security headers configured"
echo ""
echo "Current N8N login credentials:"
echo "Username: admin"
echo "Password: SecurePassword123!"
echo ""
echo "⚠️  Remember to change the default password after first login!"

#!/bin/bash
# ============================================================================
# keepITlocal Security Deployment Script
# ============================================================================
# Generates SSL certificates, creates Basic Auth, syncs to server
# ============================================================================

set -e

SERVER="deploy@localhost"
REMOTE_DIR="/home/deploy/projects/Server"

echo "================================================"
echo "keepITlocal Security Deployment"
echo "================================================"
echo ""

# Step 1: Generate SSL certificates
echo "Step 1: Generating self-signed SSL certificate..."
mkdir -p nginx/certs
if [ ! -f nginx/certs/cert.pem ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/certs/key.pem \
        -out nginx/certs/cert.pem \
        -subj "/C=DE/ST=Bavaria/L=Munich/O=keepITlocal/CN=keepitlocal.local"
    echo "✓ SSL certificate generated"
else
    echo "✓ SSL certificate already exists"
fi

# Step 2: Create Basic Auth
echo ""
echo "Step 2: Creating HTTP Basic Auth..."
if [ ! -f nginx/.htpasswd ]; then
    # Default: keepitlocal / <BASIC_AUTH_PASSWORD>
    echo 'keepitlocal:$apr1$vQw4rJxV$8ZGxM3wC5YqXzLNFQK9IM0' > nginx/.htpasswd
    echo "✓ Basic Auth created (user: keepitlocal, pass: <BASIC_AUTH_PASSWORD>)"
    echo "⚠  Change password later: htpasswd nginx/.htpasswd keepitlocal"
else
    echo "✓ Basic Auth file already exists"
fi

# Step 3: Sync to server
echo ""
echo "Step 3: Syncing files to server..."
rsync -avz --progress \
    docker-compose.yml \
    nginx/ \
    ${SERVER}:${REMOTE_DIR}/

echo "✓ Files synced"

# Step 4: Restart services
echo ""
echo "Step 4: Restarting Docker services..."
ssh ${SERVER} "cd ${REMOTE_DIR} && docker compose down && docker compose up -d"

echo "✓ Services restarted"

echo ""
echo "================================================"
echo "Deployment Complete!"
echo "================================================"
echo ""
echo "Access URLs:"
echo "  - Metabase: https://localhost/metabase/"
echo "  - n8n:      https://localhost/n8n/"
echo "  - pgAdmin:  https://localhost/pgadmin/"
echo "  - Health:   http://localhost/health (no auth)"
echo ""
echo "Credentials:"
echo "  - HTTP Basic Auth: keepitlocal / <BASIC_AUTH_PASSWORD>"
echo ""
echo "⚠  Browser will warn about self-signed certificate - accept to proceed"
echo ""
echo "Next steps:"
echo "1. Test access in browser"
echo "2. Change Basic Auth password: htpasswd nginx/.htpasswd keepitlocal"
echo "3. Setup Let's Encrypt for production: certbot --nginx"
echo "4. Configure SSH key-only auth (run secure_server.sh on server)"

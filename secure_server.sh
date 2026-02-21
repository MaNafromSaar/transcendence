#!/bin/bash
# ============================================================================
# keepITlocal Server Security Hardening Script
# ============================================================================
# Secures Docker services, configures nginx reverse proxy, sets up SSH keys
# ============================================================================

set -e

echo "================================================"
echo "keepITlocal Server Security Hardening"
echo "================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root or with sudo${NC}" 
   exit 1
fi

echo "Step 1: Generating self-signed SSL certificate..."
mkdir -p /home/deploy/projects/Server/nginx/certs
if [ ! -f /home/deploy/projects/Server/nginx/certs/cert.pem ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /home/deploy/projects/Server/nginx/certs/key.pem \
        -out /home/deploy/projects/Server/nginx/certs/cert.pem \
        -subj "/C=DE/ST=Bavaria/L=Munich/O=keepITlocal/CN=keepitlocal.local"
    echo -e "${GREEN}✓ SSL certificate generated${NC}"
else
    echo -e "${YELLOW}✓ SSL certificate already exists${NC}"
fi

echo ""
echo "Step 2: Creating HTTP Basic Auth credentials..."
# Create htpasswd file
# Default: keepitlocal / <BASIC_AUTH_PASSWORD>
# Generate with: htpasswd -c .htpasswd keepitlocal
mkdir -p /home/deploy/projects/Server/nginx
if [ ! -f /home/deploy/projects/Server/nginx/.htpasswd ]; then
    # Pre-generated hash for password: <BASIC_AUTH_PASSWORD>
    echo 'keepitlocal:$apr1$vQw4rJxV$8ZGxM3wC5YqXzLNFQK9IM0' > /home/deploy/projects/Server/nginx/.htpasswd
    echo -e "${GREEN}✓ Basic Auth created (user: keepitlocal, pass: <BASIC_AUTH_PASSWORD>)${NC}"
    echo -e "${YELLOW}⚠  Change password with: htpasswd /home/deploy/projects/Server/nginx/.htpasswd keepitlocal${NC}"
else
    echo -e "${YELLOW}✓ Basic Auth file already exists${NC}"
fi

echo ""
echo "Step 3: Configuring UFW firewall..."
# UFW rules
ufw --force enable
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (critical!)
ufw allow 22/tcp comment 'SSH'

# Allow HTTPS only (nginx reverse proxy)
ufw allow 443/tcp comment 'HTTPS'

# Optional: HTTP for redirect
ufw allow 80/tcp comment 'HTTP redirect'

# Deny direct access to services (defense in depth)
ufw deny 3000/tcp comment 'Block Metabase direct'
ufw deny 5678/tcp comment 'Block n8n direct'
ufw deny 8085/tcp comment 'Block pgAdmin direct'
ufw deny 5432/tcp comment 'Block PostgreSQL direct'

echo -e "${GREEN}✓ UFW configured${NC}"
ufw status numbered

echo ""
echo "Step 4: Setting up SSH key authentication..."
SSH_DIR="/home/deploy/.ssh"
mkdir -p "$SSH_DIR"

if [ ! -f "$SSH_DIR/authorized_keys" ]; then
    touch "$SSH_DIR/authorized_keys"
    chmod 600 "$SSH_DIR/authorized_keys"
    chown deploy:deploy "$SSH_DIR/authorized_keys"
    echo -e "${YELLOW}⚠  No SSH keys found. Add your public key:${NC}"
    echo "   ssh-copy-id -i ~/.ssh/id_rsa.pub deploy@localhost"
else
    echo -e "${GREEN}✓ SSH authorized_keys exists${NC}"
fi

# Secure SSH config
SSHD_CONFIG="/etc/ssh/sshd_config"
echo ""
echo "Step 5: Hardening SSH configuration..."

# Backup original
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.backup.$(date +%Y%m%d)"

# Apply secure settings
grep -q "^PermitRootLogin no" "$SSHD_CONFIG" || echo "PermitRootLogin no" >> "$SSHD_CONFIG"
grep -q "^PasswordAuthentication no" "$SSHD_CONFIG" || echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
grep -q "^PubkeyAuthentication yes" "$SSHD_CONFIG" || echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG"
grep -q "^ChallengeResponseAuthentication no" "$SSHD_CONFIG" || echo "ChallengeResponseAuthentication no" >> "$SSHD_CONFIG"
grep -q "^X11Forwarding no" "$SSHD_CONFIG" || echo "X11Forwarding no" >> "$SSHD_CONFIG"
grep -q "^MaxAuthTries 3" "$SSHD_CONFIG" || echo "MaxAuthTries 3" >> "$SSHD_CONFIG"
grep -q "^Protocol 2" "$SSHD_CONFIG" || echo "Protocol 2" >> "$SSHD_CONFIG"

echo -e "${YELLOW}⚠  SSH config updated. Restart SSH: systemctl restart sshd${NC}"
echo -e "${RED}⚠  IMPORTANT: Test new SSH connection before closing this session!${NC}"

echo ""
echo "Step 6: Installing fail2ban..."
if ! command -v fail2ban-client &> /dev/null; then
    apt-get update
    apt-get install -y fail2ban
    
    # Configure fail2ban for SSH
    cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 3
EOF

    systemctl enable fail2ban
    systemctl restart fail2ban
    echo -e "${GREEN}✓ fail2ban installed and configured${NC}"
else
    echo -e "${YELLOW}✓ fail2ban already installed${NC}"
fi

echo ""
echo "Step 7: Updating docker-compose services..."
cd /home/deploy/projects/Server

# Stop services
docker compose down

# Rebuild with new config
docker compose up -d

echo -e "${GREEN}✓ Services restarted with secured ports${NC}"

echo ""
echo "================================================"
echo "Security Hardening Complete!"
echo "================================================"
echo ""
echo -e "${GREEN}✓ Services now bound to localhost only${NC}"
echo -e "${GREEN}✓ Nginx reverse proxy with Basic Auth${NC}"
echo -e "${GREEN}✓ UFW firewall configured${NC}"
echo -e "${GREEN}✓ SSH hardened (keys only)${NC}"
echo -e "${GREEN}✓ fail2ban monitoring${NC}"
echo ""
echo "Access URLs:"
echo "  - Metabase: https://localhost/metabase/"
echo "  - n8n:      https://localhost/n8n/"
echo "  - pgAdmin:  https://localhost/pgadmin/"
echo ""
echo "Credentials:"
echo "  - HTTP Basic Auth: keepitlocal / <BASIC_AUTH_PASSWORD>"
echo "  - SSH: Key-based only"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Add your SSH public key: ssh-copy-id -i ~/.ssh/id_rsa.pub deploy@localhost"
echo "2. Test new SSH connection (in new terminal!)"
echo "3. Restart SSH: systemctl restart sshd"
echo "4. Change Basic Auth password: htpasswd /home/deploy/projects/Server/nginx/.htpasswd keepitlocal"
echo "5. Setup Let's Encrypt: certbot --nginx"
echo ""
echo -e "${RED}⚠  DO NOT close this SSH session until you've tested the new configuration!${NC}"

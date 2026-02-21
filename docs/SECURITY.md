# keepITlocal Server Security Implementation

## Security Architecture

### Defense in Depth - Multi-Layer Protection

```
Internet
    ↓
[UFW Firewall] ← Layer 1: Network filtering
    ↓ (Only ports 22, 80, 443)
[Nginx Reverse Proxy] ← Layer 2: HTTP Basic Auth + SSL/TLS
    ↓ (Rate limiting, security headers)
[Docker Services] ← Layer 3: Localhost-only bindings
    ↓ (127.0.0.1:xxxx)
[Service-Level Auth] ← Layer 4: Metabase/n8n/pgAdmin login
    ↓
[Database] ← Layer 5: PostgreSQL authentication
```

## Implemented Security Measures

### 1. Network Security
- **UFW Firewall**: Only ports 22 (SSH), 80 (HTTP→HTTPS redirect), 443 (HTTPS) exposed
- **Localhost-only bindings**: All Docker services bound to 127.0.0.1
  - PostgreSQL: `127.0.0.1:5432` (not publicly accessible)
  - n8n: `127.0.0.1:5678` (not publicly accessible)
  - pgAdmin: `127.0.0.1:8085` (not publicly accessible)
  - Metabase: `127.0.0.1:3000` (not publicly accessible)

### 2. Transport Security
- **SSL/TLS**: All traffic encrypted (TLSv1.2+, HIGH ciphers)
- **HTTP → HTTPS redirect**: Port 80 redirects to 443
- **Self-signed certificates**: For development (upgrade to Let's Encrypt for production)
  - Location: `/home/deploy/projects/Server/nginx/certs/`
  - cert.pem, key.pem

### 3. Authentication
- **HTTP Basic Authentication**: nginx enforces auth for all services
  - Username: `keepitlocal`
  - Default password: `<BASIC_AUTH_PASSWORD>` (change immediately!)
  - Stored in: `/home/deploy/projects/Server/nginx/.htpasswd`
- **SSH Key-Only Authentication**: Password login disabled (configured via secure_server.sh)
- **Service-Level Authentication**: Each service (Metabase, n8n, pgAdmin) has its own login

### 4. Rate Limiting & DDoS Protection
- **General endpoints**: 10 requests/second
- **API endpoints**: 20 requests/second
- **Nginx rate limiting**: Prevents brute-force attacks
- **fail2ban**: Auto-bans IPs after failed auth attempts (3 strikes → 1 hour ban)

### 5. Security Headers
All HTTP responses include:
- `X-Frame-Options: SAMEORIGIN` (clickjacking protection)
- `X-Content-Type-Options: nosniff` (MIME-sniffing protection)
- `X-XSS-Protection: 1; mode=block` (XSS protection)
- `Referrer-Policy: no-referrer` (privacy protection)
- `Server` tokens hidden (no version leakage)

### 6. Access Logging & Monitoring
- **Access logs**: `/var/log/nginx/access.log` (all requests)
- **Error logs**: `/var/log/nginx/error.log` (authentication failures, errors)
- **fail2ban logs**: `/var/log/fail2ban.log` (banned IPs)
- **Health endpoint**: `/health` (no auth required, for monitoring)

## Deployment

### Quick Deployment (Recommended)
```bash
cd /home/mana/projects/Server
chmod +x deploy_security.sh
./deploy_security.sh
```

This script:
1. Generates self-signed SSL certificate
2. Creates HTTP Basic Auth credentials
3. Syncs config to server
4. Restarts Docker services

### Full Security Hardening (Production)
Run on the server (requires root/sudo):
```bash
cd /home/deploy/projects/Server
chmod +x secure_server.sh
sudo ./secure_server.sh
```

This script:
1. Generates SSL certificates
2. Creates Basic Auth
3. Configures UFW firewall
4. Sets up SSH key-only authentication
5. Installs and configures fail2ban
6. Restarts services with security config

**⚠️ IMPORTANT**: Test new SSH connection before closing current session!

## Access Instructions

### Web Services (via Reverse Proxy)
All services accessible via HTTPS with Basic Auth:

- **Metabase**: https://localhost/metabase/
- **n8n**: https://localhost/n8n/
- **pgAdmin**: https://localhost/pgadmin/
- **Health Check**: http://localhost/health (no auth)

**Credentials**:
- HTTP Basic Auth: `keepitlocal` / `<BASIC_AUTH_PASSWORD>`
- Then each service has its own login

**Browser Warning**: Self-signed certificate will trigger warning - click "Advanced" → "Accept Risk"

### SSH Access (Key-Based)
```bash
# Add your SSH key
ssh-copy-id -i ~/.ssh/id_rsa.pub deploy@localhost

# Test connection (in NEW terminal!)
ssh deploy@localhost

# If working, restart SSH to enforce key-only
sudo systemctl restart sshd
```

### Direct Service Access (via SSH Tunnel)
For development/debugging, access services directly via SSH tunnel:
```bash
# Create tunnel
ssh -L 3000:localhost:3000 \
    -L 5678:localhost:5678 \
    -L 8085:localhost:8085 \
    -L 5432:localhost:5432 \
    deploy@localhost -N

# Then access locally
# Metabase: http://localhost:3000
# n8n: http://localhost:5678
# pgAdmin: http://localhost:8085
```

## Configuration Files

### docker-compose.yml
- All services bound to `127.0.0.1:xxxx` (localhost-only)
- nginx service with volumes for config, certs, htpasswd

### nginx/nginx.conf
- HTTP (80) → HTTPS (443) redirect
- SSL/TLS configuration
- HTTP Basic Auth for all services
- Rate limiting zones
- Reverse proxy locations: /n8n/, /metabase/, /pgadmin/
- Security headers
- Health endpoint

### nginx/.htpasswd
- HTTP Basic Auth credentials
- Generated with: `htpasswd -c .htpasswd keepitlocal`
- Change password: `htpasswd .htpasswd keepitlocal`

### nginx/certs/
- `cert.pem`: SSL certificate
- `key.pem`: SSL private key
- Self-signed (365 days validity)

## Maintenance

### Change Basic Auth Password
```bash
cd /home/mana/projects/Server/nginx
htpasswd .htpasswd keepitlocal
rsync -avz .htpasswd deploy@localhost:/home/deploy/projects/Server/nginx/
ssh deploy@localhost 'cd /home/deploy/projects/Server && docker compose restart nginx'
```

### Upgrade to Let's Encrypt (Production)
```bash
# On server
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
sudo certbot renew --dry-run  # Test auto-renewal
```

Update nginx.conf to use Let's Encrypt certs:
```nginx
ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
```

### Check fail2ban Status
```bash
# View banned IPs
sudo fail2ban-client status sshd
sudo fail2ban-client status nginx-http-auth

# Unban IP
sudo fail2ban-client set sshd unbanip 1.2.3.4
```

### Monitor Access Logs
```bash
# Live access log
docker compose logs -f nginx

# Failed auth attempts
ssh deploy@localhost 'grep "401" /var/log/nginx/error.log | tail -20'

# Show IPs accessing services
ssh deploy@localhost 'awk "{print \$1}" /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20'
```

### Firewall Management
```bash
# Check UFW status
sudo ufw status numbered

# Add rule
sudo ufw allow from 1.2.3.4 to any port 443 comment 'Trusted IP'

# Delete rule
sudo ufw delete [number]

# Reload
sudo ufw reload
```

## Security Checklist

### Before Going Live
- [ ] Change Basic Auth password from default
- [ ] Setup SSH key-only authentication
- [ ] Test SSH connection with keys before disabling passwords
- [ ] Configure UFW firewall
- [ ] Install and configure fail2ban
- [ ] Setup Let's Encrypt SSL (replace self-signed)
- [ ] Enable auto-renewal for Let's Encrypt
- [ ] Configure backup of `.htpasswd` and SSL certs
- [ ] Document access procedures for team
- [ ] Test all services via reverse proxy
- [ ] Verify direct port access is blocked (try http://localhost:3000)

### Regular Maintenance
- [ ] Review access logs weekly
- [ ] Check fail2ban reports for unusual activity
- [ ] Update Docker images monthly: `docker compose pull && docker compose up -d`
- [ ] Rotate Basic Auth password quarterly
- [ ] Audit SSH authorized_keys monthly
- [ ] Test SSL certificate renewal (Let's Encrypt every 90 days)
- [ ] Review and update UFW rules as needed

### Incident Response
If you suspect unauthorized access:
1. Check access logs: `grep "401\|403" /var/log/nginx/error.log`
2. Check fail2ban: `sudo fail2ban-client status`
3. Review PostgreSQL logs: `docker compose logs db | grep "authentication failed"`
4. Change all passwords immediately
5. Revoke compromised SSH keys
6. Ban suspicious IPs: `sudo ufw deny from 1.2.3.4`

## DSGVO Compliance

This security setup demonstrates DSGVO best practices:

1. **Data Encryption**: All traffic encrypted (TLS 1.2+)
2. **Access Control**: Multi-layer authentication
3. **Audit Trail**: Complete access logging
4. **Data Location**: Server in Germany (Local)
5. **Minimization**: Only necessary ports exposed
6. **Privacy**: No tracking, no external services
7. **Availability**: Health monitoring, automated recovery

This makes the CRM system a **"showcase for security"** - proving to German SMBs that keepITlocal can deliver DSGVO-compliant, secure solutions.

## Troubleshooting

### Cannot Access Services
```bash
# Check nginx is running
docker compose ps nginx

# Check nginx logs
docker compose logs nginx

# Test Basic Auth
curl -u keepitlocal:<BASIC_AUTH_PASSWORD> https://localhost/health -k

# Check port bindings
docker compose ps
```

### SSH Connection Refused
```bash
# If locked out, access via local console
# Temporarily re-enable password auth:
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Fix authorized_keys, then disable passwords again
```

### SSL Certificate Errors
```bash
# Regenerate certificate
cd /home/deploy/projects/Server/nginx/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout key.pem -out cert.pem \
    -subj "/C=DE/ST=Bavaria/L=Munich/O=keepITlocal/CN=keepitlocal.local"

# Restart nginx
docker compose restart nginx
```

### Rate Limiting Issues
If legitimate traffic is rate-limited, adjust nginx.conf:
```nginx
limit_req_zone $binary_remote_addr zone=general:10m rate=20r/s;  # Increase from 10r/s
limit_req_zone $binary_remote_addr zone=api:10m rate=50r/s;      # Increase from 20r/s
```

Then: `rsync -avz nginx/ deploy@localhost:/home/deploy/projects/Server/nginx/ && ssh deploy@localhost 'cd /home/deploy/projects/Server && docker compose restart nginx'`

## Cost Comparison (Security)

**keepITlocal Self-Hosted CRM Security**:
- Server: €51.04/month (Local Machine)
- SSL: €0 (self-signed) or €0 (Let's Encrypt)
- Auth: €0 (nginx Basic Auth)
- Firewall: €0 (UFW)
- Monitoring: €0 (fail2ban)
- **Total: €51.04/month**

**Commercial CRM Security** (e.g., HubSpot):
- Subscription: €45-800/month
- Built-in SSL: Included
- Auth: Included (2FA costs extra)
- No self-hosting: Data on US servers
- DSGVO compliance: Trust external provider
- **Total: €45-800/month + data privacy concerns**

**Value Proposition**: keepITlocal demonstrates "local AI" security best practices while saving €540-9,000/year vs commercial CRMs.

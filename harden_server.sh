#!/usr/bin/env bash
set -euo pipefail

# harden_local.sh
# Usage (local):
#   scp harden_local.sh user@local:/tmp/
#   ssh user@local 'sudo bash /tmp/harden_local.sh "ssh-ed25519 AAAA... yourkey"'
# Or run with environment variables:
#   sudo PUBKEY="ssh-ed25519 AAAA..." bash harden_local.sh

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

PUBKEY=${PUBKEY:-""}
DEPLOY_USER=${DEPLOY_USER:-deploy}
SSH_PORT=${SSH_PORT:-22}

echo "Starting basic hardening..."

# 1) Basic OS update
export DEBIAN_FRONTEND=noninteractive
apt update && apt -y upgrade

# 2) Create deploy user if missing
if id -u "$DEPLOY_USER" >/dev/null 2>&1; then
  echo "User $DEPLOY_USER already exists"
else
  echo "Creating user $DEPLOY_USER"
  adduser --disabled-password --gecos "" "$DEPLOY_USER"
  usermod -aG sudo "$DEPLOY_USER"
fi

# 3) Time sync
apt install -y chrony
systemctl enable --now chrony

# 4) Install common security packages
apt install -y ufw fail2ban unattended-upgrades apt-transport-https ca-certificates curl gnupg lsb-release

# 5) SSH key install if provided
if [ -n "$PUBKEY" ]; then
  echo "Installing provided SSH public key for $DEPLOY_USER"
  mkdir -p /home/$DEPLOY_USER/.ssh
  chmod 700 /home/$DEPLOY_USER/.ssh
  echo "$PUBKEY" >> /home/$DEPLOY_USER/.ssh/authorized_keys
  chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys
  chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
else
  echo "No PUBKEY provided. Please add your public key to /home/$DEPLOY_USER/.ssh/authorized_keys later."
fi

# 6) Harden sshd_config (backup first)
SSHD_CONF=/etc/ssh/sshd_config
cp -a "$SSHD_CONF" "$SSHD_CONF.bak-$(date +%s)"

# Disable root login and password auth
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' $SSHD_CONF
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' $SSHD_CONF
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' $SSHD_CONF

# Ensure AllowUsers contains deploy user (append if not present)
if ! grep -q "^AllowUsers" $SSHD_CONF; then
  echo "AllowUsers $DEPLOY_USER" >> $SSHD_CONF
else
  if ! grep -q "AllowUsers.*\b$DEPLOY_USER\b" $SSHD_CONF; then
    sed -i "s/^AllowUsers.*/& $DEPLOY_USER/" $SSHD_CONF || echo "AllowUsers $DEPLOY_USER" >> $SSHD_CONF
  fi
fi

# Optionally change SSH port: if SSH_PORT env var != 22 uncomment next lines
if [ "$SSH_PORT" -ne 22 ]; then
  echo "Setting SSH port to $SSH_PORT"
  sed -i "s/^#Port 22/Port $SSH_PORT/" $SSHD_CONF || echo "Port $SSH_PORT" >> $SSHD_CONF
  # ensure UFW allow is set later
fi

systemctl reload sshd || echo "sshd reload failed; check sshd config"

# 7) UFW configuration
ufw default deny incoming
ufw default allow outgoing
# allow SSH (port may be custom)
ufw allow ${SSH_PORT}/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# 8) fail2ban: basic jail.local for ssh
cat > /etc/fail2ban/jail.local <<'EOF'
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600
EOF
systemctl restart fail2ban

# 9) unattended-upgrades enable for security
dpkg-reconfigure -plow unattended-upgrades || true

# 10) Install Docker (official convenience script)
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh
fi

# Add deploy user to docker group
usermod -aG docker $DEPLOY_USER || true

# 11) Docker daemon hardening (safe defaults)
DAEMON_JSON=/etc/docker/daemon.json
if [ -f "$DAEMON_JSON" ]; then
  cp "$DAEMON_JSON" "$DAEMON_JSON.bak-$(date +%s)" || true
fi
cat > $DAEMON_JSON <<'EOF'
{
  "icc": false,
  "userland-proxy": false,
  "no-new-privileges": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
systemctl restart docker || echo "docker restart failed; you may need to inspect daemon.json"

# 12) Install docker-compose plugin
apt update
apt install -y docker-compose-plugin || true

# 13) Create basic directories for Docker volumes
mkdir -p /srv/docker
chown $DEPLOY_USER:$DEPLOY_USER /srv/docker

# 14) Optional: run docker bench (print a note, do not execute by default)
cat <<'NOTE'
Hardening script completed initial steps.
Optional: run the Docker Bench security script to audit the host:
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock --net host --pid host --cap-add audit_control docker/docker-bench-security
NOTE

# 15) Final notes
echo "Hardening finished. A few manual follow-ups you should consider:"
echo " - Ensure your SSH public key is trusted and you can log in as $DEPLOY_USER"
echo " - Consider configuring Local Firewall to only allow SSH from trusted IPs"
echo " - If you changed SSH port, update any firewall/security groups accordingly"
echo " - If you plan to run HashiCorp Vault, Traefik, or Vaultwarden next, I can prepare compose files"

exit 0

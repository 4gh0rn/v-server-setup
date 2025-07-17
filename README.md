# V-Server Setup: Manual vs Automated

Complete Ubuntu server configuration - from manual steps to Infrastructure as Code with Ansible.

## Table of Contents
- [Overview](#overview)
- [Manual Setup Steps](#manual-setup-steps)
- [Automated Setup with Ansible](#automated-setup-with-ansible)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [How Ansible Automates Each Task](#how-ansible-automates-each-task)
- [Testing](#testing)

## Overview

This project demonstrates two approaches to V-Server setup:
1. **Manual Configuration** - Traditional step-by-step process
2. **Ansible Automation** - Infrastructure as Code solution

The automated approach transforms hours of manual work into a reproducible, secure, and scalable process.

## Manual Setup Steps

### 1. SSH Key Setup
```bash
# On your local machine
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy key to server
ssh-copy-id user@server-ip

# Test connection
ssh user@server-ip
```

### 2. Disable Password Authentication
```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config

# Change these settings:
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no

# Restart SSH service
sudo systemctl restart sshd
```

### 3. Install and Configure NGINX
```bash
# Install NGINX
sudo apt update
sudo apt install nginx -y

# Create alternative HTML page
sudo mkdir -p /var/www/alternative
sudo nano /var/www/alternative/index.html
```

Create the NGINX site configuration:
```nginx
# /etc/nginx/sites-available/alternative
server {
    listen 80;  # HTTP port
    listen [::]:80;  # IPv6 support
    
    server_name _;  # Default server
    
    # Path to alternative HTML page
    root /var/www/alternative;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/alternative /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### 4. Configure Git
```bash
# Set user information
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"

# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "your_email@example.com"

# Display public key to add to GitHub
cat ~/.ssh/id_ed25519.pub
```

## Automated Setup with Ansible

Instead of performing these steps manually on each server, Ansible automates the entire process:

```bash
# One command replaces all manual steps
ansible-playbook -i inv_dev/hosts setup_server.yml
```

### Manual vs Automated Comparison

| Task | Manual Time | Automated Time | Error Risk |
|------|------------|----------------|------------|
| SSH Key Setup | 10-15 min | < 1 min | High (typos, permissions) |
| SSH Hardening | 15-20 min | < 1 min | High (lockout risk) |
| NGINX Setup | 20-30 min | 2-3 min | Medium (config errors) |
| Git Configuration | 5-10 min | < 1 min | Low |
| **Total per Server** | **50-75 min** | **< 5 min** | **Eliminated** |
| **10 Servers** | **8-12 hours** | **< 10 min** | **Consistent** |

## Requirements

- Ansible 2.9+
- Ubuntu Server (target)
- SSH access to the server
- Ansible Vault password (for encrypted variables)

## Quick Start

1. **Initial Setup (as root)**
   ```bash
   ansible-playbook -i inv_dev/hosts initial_setup.yml
   ```

2. **Complete Server Setup**
   ```bash
   ansible-playbook -i inv_dev/hosts setup_server.yml
   ```

## How Ansible Automates Each Task

### 1. SSH Key Management
- **Solution**: The `sshd` role automatically adds SSH public keys to authorized_keys
- **Implementation**: Keys are defined in host variables and deployed via `authorized_key` module
- **Security**: Password authentication is disabled in `sshd_config` template

### 2. SSH Security Hardening
- **Solution**: Custom `sshd_config` template enforces security best practices
- **Features**:
  - Disables password authentication
  - Enforces public key authentication only
  - Restricts access to specific users
  - Configures secure SSH settings

### 3. NGINX Web Server
- **Solution**: The `nginx` role handles installation and configuration
- **Custom HTML**: Alternative landing page deployed to `/var/www/alternative/`
- **Configuration**: 
  - Site config template in `roles/nginx/templates/etc/nginx/sites-available/alternative`
  - Automatically sets document root to `/var/www/alternative`
  - Configures port 80 for HTTP traffic
  - Includes security headers via `conf.d/security.conf`
- **Automation Benefits**: 
  - No manual file editing
  - Configuration validated before applying
  - Automatic service restart on changes

### 4. Git Configuration
- **Solution**: Handled in the `base` role
- **User Setup**: Git username and email configured for each system user
- **SSH Keys**: Generated on server for GitHub integration
- **Implementation**: Uses git config commands with user-specific variables

### Role Execution Order
```yaml
roles:
  - system      # Base system configuration and users
  - base        # Essential tools including Git
  - sudo        # Privilege management
  - sshd        # SSH security hardening
  - iptables    # Firewall protection
  - ansible     # Ansible agent setup
  - nginx       # Web server deployment
```

## Testing

### SSH Access Tests
```bash
# Test SSH key authentication
ssh -i ~/.ssh/id_rsa user@server-ip

# Verify password login is disabled
ssh -o PubKeyAuthentication=no user@server-ip
```

### NGINX Verification
```bash
# Test NGINX configuration
nginx -t

# Check custom page
curl http://server-ip
```

### Git Configuration
```bash
# Verify Git configuration
git config --global user.name
git config --global user.email
```

## Security Notes

- Never commit sensitive data (passwords, private keys)
- Use Ansible Vault for encrypted variables
- Test SSH key access before disabling password authentication
- Firewall rules are configured via iptables role
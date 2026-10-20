#!/bin/bash
# Vault Initialization Script
# Run after vault container starts: docker compose exec vault /vault/init/vault-init.sh

set -euo pipefail

VAULT_ADDR="http://127.0.0.1:8200"
VAULT_TOKEN="${VAULT_ROOT_TOKEN:-root}"

export VAULT_ADDR VAULT_TOKEN

echo "Waiting for Vault to be ready..."
until vault status >/dev/null 2>&1; do
  sleep 2
done

echo "Vault is ready. Initializing secrets engines..."

# Enable KV v2 secrets engine at secret/
vault secrets enable -path=secret kv-v2

# Enable database secrets engine for dynamic DB credentials
vault secrets enable -path=database database

# Configure database connections (example for Postgres)
# vault write database/config/postgres \
#   plugin_name=postgresql-database-plugin \
#   connection_url="postgresql://{{username}}:{{password}}@postgres:5432/postgres" \
#   allowed_roles="readonly,readwrite" \
#   username="vault" \
#   password="vault-password"

# Create policies
cat > /tmp/policy.hcl <<'EOF'
# Read-only access to secret/*
path "secret/data/*" {
  capabilities = ["read", "list"]
}
path "secret/metadata/*" {
  capabilities = ["read", "list"]
}

# Read access to database credentials
path "database/creds/readonly" {
  capabilities = ["read"]
}
EOF

vault policy write readonly /tmp/policy.hcl

cat > /tmp/policy-readwrite.hcl <<'EOF'
# Read-write access to secret/*
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/metadata/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Read-write database credentials
path "database/creds/readwrite" {
  capabilities = ["read"]
}
EOF

vault policy write readwrite /tmp/policy-readwrite.hcl

# Create example secrets
vault kv put secret/homelab/grafana \
  admin_user="admin" \
  admin_password="changeme"

vault kv put secret/homelab/postgres \
  username="postgres" \
  password="changeme" \
  database="homelab"

vault kv put secret/homelab/traefik \
  cloudflare_email="your@email.com" \
  cloudflare_api_key="your-api-key"

echo "Vault initialization complete!"
echo "Root token: ${VAULT_TOKEN}"
echo "UI: http://localhost:8200"
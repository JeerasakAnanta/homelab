# Vault Configuration for Home Lab
# Dev mode - in-memory storage, auto-unsealed
# For production: use raft storage backend with HA

ui = true
disable_mlock = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true  # Enable TLS in production with certs
}

storage "file" {
  path = "/vault/data"
}

# Dev mode settings (remove for production)
# api_addr = "http://127.0.0.1:8200"
# cluster_addr = "https://127.0.0.1:8201"
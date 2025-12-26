# Traefik Reverse Proxy

Traefik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy.

## Setup

1. Create the acme.json file with proper permissions:
   ```bash
   touch acme.json
   chmod 600 acme.json
   ```

2. Update the email address in `traefik.yml` under `certificatesResolvers.letsencrypt.acme.email`

3. Start Traefik:
   ```bash
   docker-compose up -d
   ```

## Access

- Dashboard: http://traefik.localhost:8080 (or http://your-server-ip:8080)

## Configuration

- **traefik.yml**: Static configuration file
- **config/dynamic.yml**: Dynamic configuration for middlewares and TLS settings
- **acme.json**: Let's Encrypt certificates storage

## Adding Services

To add a service to Traefik, add these labels to your docker-compose service:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myservice.rule=Host(`myservice.example.com`)"
  - "traefik.http.routers.myservice.entrypoints=https"
  - "traefik.http.routers.myservice.tls.certresolver=letsencrypt"
  - "traefik.http.services.myservice.loadbalancer.server.port=8080"
networks:
  - proxy
```

Make sure the service is on the `proxy` network:

```yaml
networks:
  proxy:
    external: true
```

## Network

All services using Traefik should be connected to the `proxy` network. The network is created automatically when starting Traefik.

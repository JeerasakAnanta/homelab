# 🧪 Homelab

This repository contains the configuration and documentation for my home lab setup, featuring various monitoring and visualization services running on Docker containers.

## 📦 Services

### 1. Glance Dashboard

A web-based dashboard providing an overview of your home lab environment.

- **Port**: 8081
- **Features**: Service status monitoring, Docker container widget
- **Location**: [glance/](glance/)

### 2. Grafana

Open-source analytics and interactive visualization platform.

- **Port**: 3080
- **Features**: Data visualization, dashboards, alerting
- **Location**: [grafana/](grafana/)

### 3. Netdata

Real-time performance and health monitoring.

- **Port**: Uses host network mode
- **Features**: System metrics, container monitoring, performance insights
- **Location**: [netdata/](netdata/)

### 4. Prometheus

Monitoring system and time-series database.

- **Port**: 9090
- **Features**: Metrics collection, alerting, powerful query language
- **Location**: [prometheus/](prometheus/)

## � Ports Overview

| Service | Port | Access URL |
|---------|------|------------|
| Glance Dashboard | 8081 | <http://localhost:8081> |
| Grafana | 3080 | <http://localhost:3080> |
| Netdata | 19999 | <http://localhost:19999> |
| Prometheus | 9090 | <http://localhost:9090> |

## �🔧 Requirements

- Docker
- Docker Compose

## 🚀 Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/JeerasakAnanta/homelab.git
   cd homelab
   ```

2. Start individual services:

   ```bash
   # Glance Dashboard
   cd glance && docker-compose up -d
   
   # Grafana
   cd grafana && docker-compose up -d
   
   # Netdata
   cd netdata && docker-compose up -d
   
   # Prometheus
   cd prometheus && docker-compose up -d
   ```

3. Access the services:
   - Glance: <http://localhost:8081>
   - Grafana: <http://localhost:3080>
   - Netdata: <http://localhost:19999>
   - Prometheus: <http://localhost:9090>

## ⚙️ Configuration

Each service has its own configuration directory:

- **Glance**: `glance/config/` - Contains dashboard configuration files
- **Grafana**: Environment variables in docker-compose.yml
- **Netdata**: `netdata/netdataconfig/`
- **Prometheus**: `prometheus/prometheus.yml`

## 📝 Notes

- Ensure all required ports are available before starting the services
- Some services may require additional environment variables (check respective docker-compose files)
- Netdata runs in host network mode for comprehensive system monitoring

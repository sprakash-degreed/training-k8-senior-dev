# Docker Compose Setup

This directory contains the Docker Compose configuration to run the sample microservices application locally.

## Quick Start

1. **Build and start all services:**
   ```bash
   docker-compose up --build
   ```

2. **Access the application:**
   - Frontend: http://localhost:3000
   - API Gateway: http://localhost:8080
   - User Service: http://localhost:3001
   - Product Service: http://localhost:5000

3. **Stop all services:**
   ```bash
   docker-compose down
   ```

## Services Overview

- **frontend**: React app served by Node.js (port 3000)
- **api-gateway**: Express.js proxy server (port 8080)
- **user-service**: Node.js + MongoDB (port 3001)
- **product-service**: Python Flask + PostgreSQL (port 5000)
- **mongodb**: MongoDB database (port 27017)
- **postgres**: PostgreSQL database (port 5432)
- **redis**: Redis cache (port 6379)

## Testing the Application

### Health Checks
```bash
# Frontend health
curl http://localhost:3000/api/health

# API Gateway health
curl http://localhost:8080/api/gateway/health

# User Service health
curl http://localhost:3001/health

# Product Service health
curl http://localhost:5000/health
```

### API Testing
```bash
# Get all users
curl http://localhost:8080/api/users/users

# Create a user
curl -X POST http://localhost:8080/api/users/users \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","email":"john@example.com"}'

# Get all products
curl http://localhost:8080/api/products/products

# Create a product
curl -X POST http://localhost:8080/api/products/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Tablet","description":"10-inch tablet","price":299.99}'
```

## Key Learning Points

1. **Service Discovery**: Services communicate using service names (e.g., `mongodb:27017`)
2. **Environment Variables**: Configuration is externalized
3. **Health Checks**: Each service provides health endpoints
4. **Data Persistence**: Volumes ensure data survives container restarts
5. **Network Isolation**: All services run in the same Docker network

## Transition to Kubernetes

After understanding how services work together in Docker Compose, we'll translate this to Kubernetes manifests in the next section.

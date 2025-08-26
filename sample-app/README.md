# Sample Microservices Application

This directory contains a sample microservices application built with Node.js and Python, designed to demonstrate Kubernetes concepts.

## Architecture

- **Frontend**: React application served by Node.js
- **API Gateway**: Node.js Express server
- **User Service**: Node.js microservice with MongoDB
- **Product Service**: Python Flask microservice with PostgreSQL
- **Redis**: Caching layer

## Services

### Frontend (React + Node.js)
- Port: 3000
- Simple UI to interact with the API

### API Gateway (Node.js)
- Port: 8080
- Routes requests to appropriate microservices
- Handles authentication and rate limiting

### User Service (Node.js)
- Port: 3001
- Manages user registration and authentication
- Uses MongoDB for data persistence

### Product Service (Python Flask)
- Port: 5000
- Manages product catalog
- Uses PostgreSQL for data persistence

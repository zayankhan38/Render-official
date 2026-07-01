# RENDER Deployment Guide

## Local Development Setup

### Prerequisites
- Docker & Docker Compose v2.0+
- Node.js 18+ (for frontend development)
- Go 1.22+ (for backend development)
- Python 3.11+ (for FastAPI development)
- PostgreSQL 16 (or use Docker)

### 1. Clone Repository
```bash
git clone https://github.com/zayankhan38/Render-official.git
cd Render-official
```

### 2. Configure Environment
```bash
cp .env.local .env.local
# Edit .env.local with your local settings
```

### 3. Start with Docker Compose
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 4. Access Services
- **Frontend**: http://localhost:3000
- **Go Backend**: http://localhost:8080
- **FastAPI**: http://localhost:8000/docs
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

---

## Production Deployment

### Prerequisites
- AWS/GCP/Azure account
- Kubernetes cluster (EKS/GKE/AKS)
- PostgreSQL managed database
- Redis managed cache
- Mux account with live streaming enabled
- Stripe account with Connect enabled

### Environment Variables (Production)
```bash
NEXT_PUBLIC_API_URL=https://api.render.app
DB_HOST=render-prod-postgres.xxx.rds.amazonaws.com
MUX_API_TOKEN=<production-token>
STRIPE_SECRET_KEY=<production-key>
JWT_SECRET=<strong-random-secret>
ADMIN_SECRET=<strong-random-secret>
```

### Kubernetes Deployment
```bash
# Build Docker images
docker build -t render-frontend:latest ./frontend
docker build -t render-go:latest ./backend/go
docker build -t render-fastapi:latest ./backend/fastapi

# Push to registry
docker tag render-frontend:latest YOUR_REGISTRY/render-frontend:latest
docker push YOUR_REGISTRY/render-frontend:latest
# ... repeat for other images

# Deploy to Kubernetes
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/redis.yaml
kubectl apply -f k8s/backend-go.yaml
kubectl apply -f k8s/backend-fastapi.yaml
kubectl apply -f k8s/frontend.yaml
```

### Database Migrations
```bash
# Connect to production database
psql -h render-prod-postgres.xxx.rds.amazonaws.com -U render_user -d render_prod

# Run migrations
\i database/migrations/001_initial_schema.sql
```

### Enable SSL/TLS
```bash
# Use Let's Encrypt via cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create certificate
kubectl apply -f k8s/certificate.yaml
```

### Monitoring & Logging
```bash
# Enable CloudWatch/Stackdriver logging
kubectl apply -f k8s/logging.yaml

# Set up Prometheus monitoring
kubectl apply -f k8s/prometheus.yaml
```

---

## Troubleshooting

### Database Connection Issues
```bash
# Test PostgreSQL connection
psql -h localhost -U render_user -d render_dev -c "SELECT version();"
```

### Service Health Checks
```bash
curl http://localhost:8080/health
curl http://localhost:8000/health
curl http://localhost:3000
```

### View Container Logs
```bash
docker-compose logs backend_go
docker-compose logs backend_fastapi
docker-compose logs frontend
```

---

## Performance Optimization

### Frontend
- Enable Next.js Image Optimization
- Implement Code Splitting
- Use Service Workers for offline support
- Enable Gzip compression

### Backend (Go)
- Enable connection pooling
- Use Redis for caching
- Implement rate limiting
- Use HTTP/2 push

### FastAPI
- Enable uvicorn worker pool
- Use async/await patterns
- Implement caching with Redis
- Add request compression

### Database
- Create indexes on frequently queried columns
- Implement connection pooling
- Use read replicas for scaling
- Archive old data regularly

---

## Backup & Disaster Recovery

### Database Backups
```bash
# Automated daily backups
pg_dump -h render-prod-postgres.xxx.rds.amazonaws.com -U render_user -d render_prod > backup_$(date +%Y%m%d).sql
```

### Redis Backups
```bash
# Automated RDB snapshots
redis-cli BGSAVE
```

### Recovery Procedure
```bash
# Restore from database backup
psql -h localhost -U render_user -d render_prod < backup_YYYYMMDD.sql

# Restore Redis
redis-cli --rdb /path/to/dump.rdb
```

---

## Security Checklist

- [ ] Enable HTTPS/TLS on all endpoints
- [ ] Rotate JWT secrets regularly
- [ ] Enable rate limiting on API
- [ ] Implement DDoS protection
- [ ] Enable database encryption
- [ ] Set up WAF rules
- [ ] Regular security audits
- [ ] Enable VPC/network isolation
- [ ] Configure firewall rules
- [ ] Implement log retention policies

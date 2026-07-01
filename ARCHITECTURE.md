# RENDER Architecture Documentation

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        RENDER PLATFORM                       │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────┐  ┌──────────────────────┐
│   FRONTEND (Web)     │  │  GAMEPAD CONTROLLER  │
│   Next.js + TS       │  │  Console Support     │
│   Tailwind CSS       │  │  Focus Mapping       │
│   Dark Theme (#09090b)│  └──────────────────────┘
│   Phaser.js Arcade   │
└──────────────┬───────┘
               │ HTTP/WebSocket
        ┌──────▼──────────────────────────┐
        │   API GATEWAY / Load Balancer    │
        └──────┬──────────────────────────┘
               │
        ┌──────┼──────────────────────────┐
        │      │                          │
   ┌────▼──┐ ┌─▼─────────────┐   ┌──────▼─────┐
   │  Go   │ │  FastAPI      │   │  Streaming │
   │ Main  │ │  Copyright    │   │  (RTMP)    │
   │Server │ │  Shield (Ash  │   │            │
   │Port   │ │  AI)          │   │ Mux SDK    │
   │8080   │ │  Port 8000    │   │            │
   └────┬──┘ └─┬─────────────┘   └──────┬─────┘
        │      │                        │
        └──────┼────────┬────────────────┘
               │        │
        ┌──────▼────────▼──────────────┐
        │   PostgreSQL Database         │
        │   - Users (profiles)          │
        │   - Streams (metadata)        │
        │   - Revenue (payouts)         │
        │   - Leagues (50-person)       │
        │   - Subscriptions             │
        └────────────────┬──────────────┘
                         │
        ┌────────────────┴──────────────┐
        │                               │
   ┌────▼──────┐              ┌────────▼──┐
   │   Redis   │              │   Stripe  │
   │   Cache   │              │  Connect  │
   │           │              │ (Revenue) │
   └───────────┘              └───────────┘
```

## Component Details

### Frontend (Next.js + TypeScript)
- **Framework**: Next.js 14 with App Router
- **Styling**: Tailwind CSS with dark mode (#09090b)
- **State Management**: Zustand for global state
- **API Client**: Axios with interceptors
- **Game Integration**: Phaser.js for web arcade
- **Gamepad Support**: Gamepad API with console controller mapping

### Backend - Go Server (Port 8080)
- **Framework**: Gorilla Mux for routing
- **Database**: PostgreSQL with connection pooling
- **Cache**: Redis for session management
- **Authentication**: JWT with refresh tokens
- **Streaming**: Mux SDK for video delivery
- **Payment**: Stripe Connect integration

### Backend - FastAPI (Port 8000)
- **Framework**: FastAPI with async/await
- **AI Services**: Audio/video fingerprinting (Ash AI Copyright Shield)
- **Anti-Bot**: Behavioral verification system
- **Database**: PostgreSQL for fingerprint storage
- **Rate Limiting**: Token bucket algorithm

### Database Schema

#### Users Table
```sql
id, uuid, username, email, password_hash, avatar_url, 
is_creator, is_verified, stripe_connect_id, total_subscribers, 
total_views, created_at, updated_at
```

#### Streams Table
```sql
id, uuid, creator_id, title, description, mux_video_id, 
rtmp_stream_key, status, is_live, copyright_shield_status, 
view_count, likes_count, duration_seconds, started_at, 
ended_at, created_at, updated_at
```

#### Viewer Leagues Table
```sql
id, uuid, season, bracket_number, status, max_members (50), 
created_at, completed_at
```

#### Revenue Payouts Table
```sql
id, uuid, creator_id, stream_id, gross_revenue, 
creator_amount (90%), platform_amount (10%), 
payout_status, stripe_payout_id, created_at, processed_at
```

## Data Flow

### Video Upload Flow
1. Creator uploads video via Next.js frontend
2. FastAPI scans for copyright (Ash AI fingerprinting)
3. If blocked → return error to creator
4. If passed → store metadata in PostgreSQL
5. Mux encodes video
6. Return stream URL to frontend

### Viewer Engagement Flow
1. Viewer watches stream
2. Go backend tracks view metrics in PostgreSQL
3. Redis caches view count for real-time updates
4. Viewer points earned toward 50-person league bracket
5. League rankings updated in real-time

### Revenue Flow
1. Stream completes
2. Ad revenue calculated based on watch time
3. Stripe Connect processes 90/10 split
4. Payout record created in revenue_payouts table
5. Creator receives payment via Stripe
6. Platform retains 10% commission

### Gamepad Input Flow
1. Gamepad connected to browser
2. Gamepad API detects button presses
3. Map to virtual cursor movement/selection
4. Send action via WebSocket to Go backend
5. Backend processes action and returns result

## API Endpoints

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Refresh JWT token

### Streams
- `GET /streams` - List active/completed streams
- `POST /streams/start` - Start new stream
- `POST /streams/{id}/end` - End stream
- `GET /streams/{id}` - Get stream details
- `PUT /streams/{id}` - Update stream metadata

### Users
- `GET /user/{id}/profile` - Get user profile
- `PUT /user/{id}/profile` - Update profile
- `GET /user/{id}/streams` - Get user's streams
- `GET /user/{id}/subscribers` - Get subscriber list

### Leagues
- `GET /leagues/brackets` - List 50-person brackets
- `POST /leagues/join` - Join league bracket
- `GET /leagues/{id}/standings` - Get league rankings
- `GET /leagues/{id}/members` - Get bracket members

### Revenue
- `GET /revenue/analytics` - Creator earnings analytics
- `POST /revenue/payout` - Request payout
- `GET /revenue/history` - Payout history

### Copyright Shield (FastAPI)
- `POST /upload/scan` - Pre-upload copyright scan
- `GET /upload/status/{id}` - Get scan status

### Anti-Bot (FastAPI)
- `POST /verify/bot` - Bot verification check
- `POST /verify/captcha` - CAPTCHA verification

## Security Architecture

### Authentication
- JWT tokens with 24-hour expiry
- Refresh tokens with 7-day expiry
- Password hashing with bcrypt
- Rate limiting on auth endpoints

### Authorization
- Role-based access control (RBAC)
- Creator-only endpoints
- Admin-only moderation tools
- User-scoped data access

### Data Protection
- TLS/SSL encryption in transit
- AES-256 encryption at rest (sensitive data)
- CSRF token validation
- SQL injection prevention (parameterized queries)
- XSS protection via CSP headers

### Zero-Strike Copyright Policy
- Pre-upload scanning via Ash AI
- Audio/video fingerprinting
- Content matching database
- Automatic blocking before publication
- Creator notification of violations

## Caching Strategy

### Redis Cache Layers
1. **Session Cache**: User authentication/profile
2. **Stream Cache**: Active stream metadata
3. **League Cache**: Bracket standings and rankings
4. **View Cache**: Real-time view count updates
5. **User Cache**: Subscriber/creator relationships

### Cache Invalidation
- TTL-based (auto-expire after N seconds)
- Event-based (invalidate on updates)
- Manual purge (admin tools)

## Scaling Considerations

### Horizontal Scaling
- Load balanced Go servers (multiple instances)
- FastAPI workers (Uvicorn with gunicorn)
- PostgreSQL read replicas
- Redis cluster for distributed cache

### Vertical Scaling
- Increase CPU/memory for Go backend
- Increase database connection pool
- Increase FastAPI worker count

### Database Optimization
- Indexes on frequently queried columns
- Partitioning streams by date
- Archiving old data
- Connection pooling (pgBouncer)

## Monitoring & Observability

### Metrics
- Request latency (P50, P95, P99)
- Error rates by endpoint
- Database query performance
- Cache hit rates
- Stream quality metrics (bitrate, latency)

### Logging
- Structured logging in JSON format
- Centralized log aggregation (ELK/Splunk)
- Error tracking (Sentry)
- Audit logs for admin actions

### Alerting
- High error rate alerts
- Database connection pool exhaustion
- Streaming latency spikes
- Copyright violations trending
- Revenue discrepancies

## Deployment Architecture

### Development
- Docker Compose with all services
- Local PostgreSQL + Redis
- Hot reloading for frontend/backend

### Staging
- Kubernetes on managed service (EKS/GKE/AKS)
- Managed PostgreSQL (RDS/CloudSQL)
- Managed Redis (ElastiCache/Memorystore)
- Production-like configuration

### Production
- Kubernetes cluster with auto-scaling
- Multi-zone PostgreSQL with failover
- Redis cluster with persistence
- CDN for static assets
- WAF and DDoS protection

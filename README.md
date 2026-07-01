# 🔴 RENDER - Next-Gen Video Streaming Platform

**A high-performance, gamified video streaming platform with AI-powered copyright protection, creator revenue optimization, and console gamepad support.**

---

## 📋 Tech Stack

### Frontend
- **Next.js 14** (React + TypeScript)
- **Tailwind CSS** (Dark mode: `#09090b` with vibrant red accents)
- **Phaser.js** (Web arcade games)
- **Gamepad API** (Console controller support)

### Backend
- **Go 1.22+** (High-speed streaming server)
- **Python FastAPI** (Ash AI Copyright Shield microservice)
- **PostgreSQL 16** (User profiles, subscriber metrics, revenue tracking, 50-person leagues)

### Streaming & Payment
- **Mux Video SDK** (On-demand streams + RTMP live streaming)
- **Stripe Connect** (90/10 creator/platform revenue split)

### AI & Moderation
- **Ash AI Copyright Shield** (Pre-upload audio/video fingerprinting - Zero-Strike Policy)
- **Anti-bot Verification** (FastAPI microservice)
- **Admin Moderation Dashboard** (Catch AI spam, view bot activity)

---

## 🚀 Project Structure

```
RENDER-official/
├── frontend/                 # Next.js TypeScript app
│   ├── app/                  # App router pages
│   ├── components/           # React components
│   ├── lib/                  # Utilities, API clients
│   ├── styles/               # Global Tailwind config
│   ├── public/               # Static assets
│   └── package.json
│
├── backend/
│   ├── go/                   # Go streaming server
│   │   ├── main.go
│   │   ├── handlers/         # HTTP handlers
│   │   ├── models/           # Data models
│   │   ├── services/         # Business logic
│   │   ├── migrations/       # SQL migrations
│   │   ├── go.mod
│   │   └── Dockerfile
│   │
│   └── fastapi/              # Python Ash AI Copyright Shield
│       ├── main.py
│       ├── routes/           # API endpoints
│       ├── services/         # AI fingerprinting logic
│       ├── models/           # Pydantic models
│       ├── requirements.txt
│       └── Dockerfile
│
├── database/
│   └── migrations/           # PostgreSQL schema migrations
│
├── docker-compose.yml        # Development environment
├── .env.local                # Local dev variables
└── README.md
```

---

## 🎮 Core Features

### 1. **Video Streaming**
- Mux on-demand streams
- Custom RTMP livestream layer
- Adaptive bitrate encoding

### 2. **Creator Revenue Split**
- Automated 90% creator / 10% platform split via Stripe Connect
- Real-time revenue tracking dashboard

### 3. **Ash AI Copyright Shield**
- Pre-upload audio/video fingerprinting
- Blocks copyright material before going live
- Zero-Strike Policy enforcement

### 4. **Gamified Viewer Leagues**
- 50-person brackets
- Physical Viewer Play Button claims
- Automated reward distribution

### 5. **Premium Pass Bundle**
- Ad-free streaming
- Integrated TypeScript/Phaser.js web arcade panel
- Exclusive league access

### 6. **Admin Moderation Dashboard**
- Catch low-effort AI video spam
- Bot detection and reporting
- Real-time viewer metrics

### 7. **Console Gamepad Support**
- Full gamepad mapping for web and PC
- Dark theme optimized for TV viewing

---

## 🔧 Setup & Running Locally

### Prerequisites
- Docker & Docker Compose
- Node.js 18+
- Go 1.22+
- Python 3.11+
- PostgreSQL 16 (or use Docker)

### Quick Start (Docker)

```bash
# Clone the repository
git clone https://github.com/zayankhan38/Render-official.git
cd Render-official

# Copy environment variables
cp .env.local.example .env.local

# Start all services with Docker Compose
docker-compose up -d

# Wait for all services to be healthy
docker-compose ps

# Verify services
curl http://localhost:8080/health        # Go server
curl http://localhost:8000/docs          # FastAPI docs
open http://localhost:3000               # Frontend
```

### Manual Start (Development)

#### 1. Start PostgreSQL
```bash
cd database
# Use Docker or local PostgreSQL
docker run --name render_postgres -e POSTGRES_PASSWORD=render_password_dev -d -p 5432:5432 postgres:16-alpine
```

#### 2. Start Go Backend
```bash
cd backend/go
go mod download
go run main.go
# Server runs on http://localhost:8080
```

#### 3. Start FastAPI Microservice
```bash
cd backend/fastapi
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
# API docs at http://localhost:8000/docs
```

#### 4. Start Frontend
```bash
cd frontend
npm install
npm run dev
# App runs on http://localhost:3000
```

---

## 📊 Environment Variables

See `.env.local` for all available variables:

- `NEXT_PUBLIC_API_URL` - Go backend URL
- `NEXT_PUBLIC_FASTAPI_URL` - FastAPI microservice URL
- `DB_*` - PostgreSQL connection
- `MUX_*` - Mux video SDK credentials
- `STRIPE_*` - Stripe Connect credentials
- `JWT_SECRET` - Authentication secret
- `ADMIN_SECRET` - Admin panel access

---

## 🧪 Testing

### Frontend Tests
```bash
cd frontend
npm run test
```

### Backend Tests
```bash
cd backend/go
go test ./...
```

### FastAPI Tests
```bash
cd backend/fastapi
pytest
```

---

## 📡 API Endpoints

### Go Backend (Port 8080)
- `POST /auth/register` - Create account
- `POST /auth/login` - User login
- `GET /streams` - List active streams
- `POST /streams/start` - Start live stream
- `GET /user/:id/profile` - User profile
- `GET /leagues/brackets` - Get 50-person brackets
- `POST /revenue/payout` - Trigger revenue split

### FastAPI (Port 8000)
- `POST /upload/scan` - Pre-upload copyright scan
- `POST /verify/bot` - Anti-bot verification
- `GET /status` - Service health

---

## 🎮 Gamepad Controller Mapping

```
A Button (Green)      - Select/Play
B Button (Red)        - Cancel/Back
X Button (Blue)       - Menu
Y Button (Yellow)     - Options
LB/RB                 - Stream Navigation
LT/RT                 - Volume Control
Left Stick            - Menu Navigation
Right Stick           - Camera/View Control
Start                 - Pause/Resume
Select                - Admin Panel
```

---

## 🛡️ Security Features

- **JWT Authentication** with 24-hour expiry
- **Refresh tokens** (7-day expiry)
- **Anti-bot verification** on upload
- **Zero-Strike Copyright Policy** (pre-upload scanning)
- **Admin-only moderation tools**
- **Rate limiting** on API endpoints

---

## 🚢 Deployment

### Production Checklist
- [ ] Update `.env.production` with real Mux/Stripe keys
- [ ] Run database migrations on production DB
- [ ] Enable Redis caching
- [ ] Configure CDN for video delivery
- [ ] Set up SSL/TLS certificates
- [ ] Deploy with Kubernetes or Docker Swarm

---

## 📞 Support & Contribution

For issues, questions, or contributions:
1. Open a GitHub issue
2. Submit a pull request
3. Contact: [your-contact-info]

---

## 📄 License

Proprietary - RENDER © 2024

---

**Happy streaming! 🎬**

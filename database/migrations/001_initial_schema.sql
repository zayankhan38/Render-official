-- RENDER Database Schema v1.0
-- PostgreSQL 16+

-- Drop existing tables if they exist (for development)
DROP TABLE IF EXISTS viewer_league_members CASCADE;
DROP TABLE IF EXISTS viewer_leagues CASCADE;
DROP TABLE IF EXISTS revenue_payouts CASCADE;
DROP TABLE IF EXISTS stream_viewers CASCADE;
DROP TABLE IF EXISTS streams CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,
    bio TEXT,
    is_creator BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    stripe_connect_id VARCHAR(100),
    total_subscribers INTEGER DEFAULT 0,
    total_views BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT email_valid CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_uuid ON users(uuid);

-- Subscriptions table
CREATE TABLE subscriptions (
    id SERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    subscriber_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    creator_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_type VARCHAR(50) DEFAULT 'free', -- 'free', 'premium', 'vip'
    premium_pass_active BOOLEAN DEFAULT FALSE,
    ad_free BOOLEAN DEFAULT FALSE,
    arcade_access BOOLEAN DEFAULT FALSE,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    UNIQUE(subscriber_id, creator_id)
);

CREATE INDEX idx_subscriptions_creator ON subscriptions(creator_id);
CREATE INDEX idx_subscriptions_subscriber ON subscriptions(subscriber_id);

-- Streams table
CREATE TABLE streams (
    id SERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    creator_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    mux_video_id VARCHAR(100),
    rtmp_stream_key VARCHAR(100),
    status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'live', 'processing', 'completed', 'blocked'
    is_live BOOLEAN DEFAULT FALSE,
    is_ai_generated BOOLEAN DEFAULT FALSE,
    copyright_shield_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'passed', 'flagged', 'blocked'
    view_count BIGINT DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    duration_seconds INTEGER,
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_streams_creator ON streams(creator_id);
CREATE INDEX idx_streams_status ON streams(status);
CREATE INDEX idx_streams_copyright_status ON streams(copyright_shield_status);

-- Stream viewers table (for tracking engagement)
CREATE TABLE stream_viewers (
    id SERIAL PRIMARY KEY,
    stream_id INTEGER NOT NULL REFERENCES streams(id) ON DELETE CASCADE,
    viewer_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    watched_seconds INTEGER DEFAULT 0,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    UNIQUE(stream_id, viewer_id)
);

CREATE INDEX idx_stream_viewers_stream ON stream_viewers(stream_id);
CREATE INDEX idx_stream_viewers_viewer ON stream_viewers(viewer_id);

-- Viewer Leagues table (50-person brackets)
CREATE TABLE viewer_leagues (
    id SERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    season INTEGER NOT NULL,
    bracket_number INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'completed', 'cancelled'
    max_members INTEGER DEFAULT 50,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    UNIQUE(season, bracket_number)
);

CREATE INDEX idx_leagues_season ON viewer_leagues(season);

-- Viewer League Members table
CREATE TABLE viewer_league_members (
    id SERIAL PRIMARY KEY,
    league_id INTEGER NOT NULL REFERENCES viewer_leagues(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    points INTEGER DEFAULT 0,
    rank INTEGER,
    play_button_claimed BOOLEAN DEFAULT FALSE,
    play_button_url TEXT,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(league_id, user_id)
);

CREATE INDEX idx_league_members_league ON viewer_league_members(league_id);
CREATE INDEX idx_league_members_user ON viewer_league_members(user_id);

-- Revenue Payouts table
CREATE TABLE revenue_payouts (
    id SERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    creator_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stream_id INTEGER REFERENCES streams(id) ON DELETE SET NULL,
    gross_revenue DECIMAL(12, 2) NOT NULL,
    creator_amount DECIMAL(12, 2) NOT NULL, -- 90%
    platform_amount DECIMAL(12, 2) NOT NULL, -- 10%
    payout_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    stripe_payout_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP
);

CREATE INDEX idx_payouts_creator ON revenue_payouts(creator_id);
CREATE INDEX idx_payouts_status ON revenue_payouts(payout_status);

-- Add triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_streams_updated_at BEFORE UPDATE ON streams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data (optional)
INSERT INTO users (username, email, password_hash, first_name, is_creator, is_verified)
VALUES 
    ('admin', 'admin@render.local', 'hashed_password', 'Admin User', TRUE, TRUE),
    ('creator1', 'creator1@render.local', 'hashed_password', 'Creator One', TRUE, FALSE),
    ('viewer1', 'viewer1@render.local', 'hashed_password', 'Viewer One', FALSE, FALSE);

INSERT INTO viewer_leagues (season, bracket_number)
VALUES (1, 1);

LOG 'RENDER Database Schema initialized successfully';

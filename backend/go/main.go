package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
	"github.com/redis/go-redis/v9"
)

var (
	db    *sql.DB
	rdb   *redis.Client
	port  = os.Getenv("GO_PORT")
	dbURL = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=%s",
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_SSL_MODE"),
	)
)

func init() {
	if port == "" {
		port = "8080"
	}
}

func main() {
	// Initialize database
	var err error
	db, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Test database connection
	if err = db.Ping(); err != nil {
		log.Fatalf("Database ping failed: %v", err)
	}
	log.Println("✅ Connected to PostgreSQL")

	// Initialize Redis
	rdb = redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
	})
	if err = rdb.Ping(context.Background()).Err(); err != nil {
		log.Printf("Redis connection warning (optional): %v", err)
	}
	log.Println("✅ Redis initialized")

	// Setup routes
	router := mux.NewRouter()

	// Health check
	router.HandleFunc("/health", handleHealth).Methods("GET")

	// Auth endpoints
	router.HandleFunc("/auth/register", handleRegister).Methods("POST")
	router.HandleFunc("/auth/login", handleLogin).Methods("POST")

	// Stream endpoints
	router.HandleFunc("/streams", handleListStreams).Methods("GET")
	router.HandleFunc("/streams/start", handleStartStream).Methods("POST")
	router.HandleFunc("/streams/{id}/end", handleEndStream).Methods("POST")

	// User endpoints
	router.HandleFunc("/user/{id}/profile", handleGetProfile).Methods("GET")
	router.HandleFunc("/user/{id}/profile", handleUpdateProfile).Methods("PUT")

	// League endpoints
	router.HandleFunc("/leagues/brackets", handleGetBrackets).Methods("GET")
	router.HandleFunc("/leagues/join", handleJoinLeague).Methods("POST")

	// Revenue endpoints
	router.HandleFunc("/revenue/payout", handleRevenuePayout).Methods("POST")
	router.HandleFunc("/revenue/analytics", handleRevenueAnalytics).Methods("GET")

	// Middleware
	router.Use(loggingMiddleware)
	router.Use(corsMiddleware)

	// Start server
	server := &http.Server{
		Addr:         ":" + port,
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Printf("🚀 RENDER Backend (Go) starting on http://localhost:%s\n", port)

	// Graceful shutdown
	go func() {
		c := make(chan os.Signal, 1)
		signal.Notify(c, os.Interrupt)
		<-c
		log.Println("\n🛑 Shutting down server...")
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		if err := server.Shutdown(ctx); err != nil {
			log.Printf("Server shutdown error: %v", err)
		}
	}()

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Server error: %v", err)
	}

	log.Println("Server stopped.")
}

// Handlers

func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"status": "healthy",
		"service": "render-go-backend",
		"timestamp": time.Now().UTC().String(),
	})
}

func handleRegister(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "User registration endpoint",
		"status": "ready",
	})
}

func handleLogin(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "User login endpoint",
		"status": "ready",
	})
}

func handleListStreams(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"streams": []interface{}{},
		"total": 0,
	})
}

func handleStartStream(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Stream started",
		"status": "live",
	})
}

func handleEndStream(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Stream ended",
	})
}

func handleGetProfile(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"id": mux.Vars(r)["id"],
		"username": "creator",
		"subscribers": 0,
	})
}

func handleUpdateProfile(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Profile updated",
	})
}

func handleGetBrackets(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"brackets": []interface{}{},
		"bracket_size": 50,
	})
}

func handleJoinLeague(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Joined league",
	})
}

func handleRevenuePayout(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Payout processed",
		"creator_split": 0.90,
		"platform_split": 0.10,
	})
}

func handleRevenueAnalytics(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"total_revenue": 0,
		"creator_earnings": 0,
		"platform_earnings": 0,
	})
}

// Middleware

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		log.Printf("%s %s %s", r.Method, r.RequestURI, time.Since(start))
		next.ServeHTTP(w, r)
	})
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

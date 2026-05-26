package main

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
)

type user struct {
	ID       string `json:"id"`
	Username string `json:"username"`
}

type signInRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type signInResponse struct {
	User  user   `json:"user"`
	Token string `json:"token"`
}

type errorResponse struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

type sessionStore struct {
	mu       sync.RWMutex
	byToken  map[string]user
}

func newSessionStore() *sessionStore {
	return &sessionStore{byToken: make(map[string]user)}
}

func (s *sessionStore) create(u user) (string, error) {
	token, err := randomToken()
	if err != nil {
		return "", err
	}
	s.mu.Lock()
	s.byToken[token] = u
	s.mu.Unlock()
	return token, nil
}

func (s *sessionStore) get(token string) (user, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	u, ok := s.byToken[token]
	return u, ok
}

func (s *sessionStore) revoke(token string) {
	s.mu.Lock()
	delete(s.byToken, token)
	s.mu.Unlock()
}

func randomToken() (string, error) {
	buf := make([]byte, 24)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	return hex.EncodeToString(buf), nil
}

func main() {
	addr := os.Getenv("ADDR")
	if addr == "" {
		addr = ":8080"
	}

	sessions := newSessionStore()

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(15 * time.Second))
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: false,
		MaxAge:           300,
	}))

	r.Get("/health", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})

	r.Route("/api/auth", func(r chi.Router) {
		r.Post("/sign-in", signInHandler(sessions))
		r.Post("/sign-out", authMiddleware(sessions, signOutHandler(sessions)))
		r.Get("/me", authMiddleware(sessions, meHandler()))
	})

	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatal(err)
	}
}

func signInHandler(sessions *sessionStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req signInRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			writeError(w, http.StatusBadRequest, "invalid_body", "Request body is not valid JSON.")
			return
		}
		if strings.TrimSpace(req.Username) == "" || req.Password == "" {
			writeError(w, http.StatusUnauthorized, "invalid_credentials", "Username and password are required.")
			return
		}

		u := user{
			ID:       "fake-" + req.Username,
			Username: req.Username,
		}
		token, err := sessions.create(u)
		if err != nil {
			writeError(w, http.StatusInternalServerError, "token_error", "Failed to issue session token.")
			return
		}
		writeJSON(w, http.StatusOK, signInResponse{User: u, Token: token})
	}
}

func signOutHandler(sessions *sessionStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token, _ := tokenFromHeader(r)
		sessions.revoke(token)
		w.WriteHeader(http.StatusNoContent)
	}
}

type ctxKey string

const userCtxKey ctxKey = "user"

func meHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		u, ok := r.Context().Value(userCtxKey).(user)
		if !ok {
			writeError(w, http.StatusUnauthorized, "unauthenticated", "Missing or invalid token.")
			return
		}
		writeJSON(w, http.StatusOK, u)
	}
}

func authMiddleware(sessions *sessionStore, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token, err := tokenFromHeader(r)
		if err != nil {
			writeError(w, http.StatusUnauthorized, "unauthenticated", err.Error())
			return
		}
		u, ok := sessions.get(token)
		if !ok {
			writeError(w, http.StatusUnauthorized, "unauthenticated", "Session token is not recognized.")
			return
		}
		ctx := context.WithValue(r.Context(), userCtxKey, u)
		next.ServeHTTP(w, r.WithContext(ctx))
	}
}

func tokenFromHeader(r *http.Request) (string, error) {
	header := r.Header.Get("Authorization")
	if header == "" {
		return "", errors.New("Authorization header is required.")
	}
	parts := strings.SplitN(header, " ", 2)
	if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") || parts[1] == "" {
		return "", errors.New("Authorization header must be a Bearer token.")
	}
	return parts[1], nil
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(body); err != nil {
		log.Printf("encode response: %v", err)
	}
}

func writeError(w http.ResponseWriter, status int, code, message string) {
	writeJSON(w, status, errorResponse{Code: code, Message: message})
}

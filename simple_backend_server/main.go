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
	"github.com/golang-jwt/jwt/v5"
)

const (
	accessTokenTTL  = 15 * time.Minute
	refreshTokenTTL = 30 * 24 * time.Hour
)

type user struct {
	ID       string `json:"id"`
	Username string `json:"username"`
}

type signInRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type tokenPair struct {
	User         user   `json:"user"`
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int64  `json:"expires_in"`
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type errorResponse struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

type refreshEntry struct {
	user      user
	expiresAt time.Time
}

type refreshStore struct {
	mu      sync.Mutex
	entries map[string]refreshEntry
}

func newRefreshStore() *refreshStore {
	return &refreshStore{entries: make(map[string]refreshEntry)}
}

func (s *refreshStore) issue(u user) (string, error) {
	token, err := randomToken()
	if err != nil {
		return "", err
	}
	s.mu.Lock()
	s.entries[token] = refreshEntry{user: u, expiresAt: time.Now().Add(refreshTokenTTL)}
	s.mu.Unlock()
	return token, nil
}

// rotate consumes the supplied refresh token and, if still valid, returns the
// associated user and a freshly issued refresh token. The old token is always
// invalidated, even when expired, to prevent reuse.
func (s *refreshStore) rotate(token string) (user, string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	entry, ok := s.entries[token]
	delete(s.entries, token)
	if !ok {
		return user{}, "", errors.New("refresh token is not recognized")
	}
	if time.Now().After(entry.expiresAt) {
		return user{}, "", errors.New("refresh token is expired")
	}
	newToken, err := randomToken()
	if err != nil {
		return user{}, "", err
	}
	s.entries[newToken] = refreshEntry{user: entry.user, expiresAt: time.Now().Add(refreshTokenTTL)}
	return entry.user, newToken, nil
}

func (s *refreshStore) revoke(token string) {
	s.mu.Lock()
	delete(s.entries, token)
	s.mu.Unlock()
}

func randomToken() (string, error) {
	buf := make([]byte, 24)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	return hex.EncodeToString(buf), nil
}

type jwtIssuer struct {
	secret []byte
}

func newJWTIssuer(secret []byte) *jwtIssuer {
	return &jwtIssuer{secret: secret}
}

type accessClaims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

func (j *jwtIssuer) sign(u user) (string, error) {
	now := time.Now()
	claims := accessClaims{
		Username: u.Username,
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   u.ID,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(accessTokenTTL)),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(j.secret)
}

func (j *jwtIssuer) parse(raw string) (user, error) {
	claims := &accessClaims{}
	_, err := jwt.ParseWithClaims(raw, claims, func(t *jwt.Token) (any, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return j.secret, nil
	})
	if err != nil {
		return user{}, err
	}
	return user{ID: claims.Subject, Username: claims.Username}, nil
}

func main() {
	addr := os.Getenv("ADDR")
	if addr == "" {
		addr = ":8080"
	}

	secret := []byte(os.Getenv("JWT_SECRET"))
	if len(secret) == 0 {
		log.Print("warning: JWT_SECRET not set, using insecure dev default")
		secret = []byte("dev-only-secret-do-not-use-in-prod")
	}

	issuer := newJWTIssuer(secret)
	refreshes := newRefreshStore()
	bookmarks := newBookmarkStore()

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
		r.Post("/sign-in", signInHandler(issuer, refreshes))
		r.Post("/refresh", refreshHandler(issuer, refreshes))
		r.Post("/sign-out", signOutHandler(refreshes))
		r.Get("/me", authMiddleware(issuer, meHandler()))
	})

	registerBookmarkRoutes(r, issuer, bookmarks)

	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatal(err)
	}
}

func signInHandler(issuer *jwtIssuer, refreshes *refreshStore) http.HandlerFunc {
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
		pair, err := issueTokens(issuer, refreshes, u)
		if err != nil {
			writeError(w, http.StatusInternalServerError, "token_error", "Failed to issue tokens.")
			return
		}
		writeJSON(w, http.StatusOK, pair)
	}
}

func refreshHandler(issuer *jwtIssuer, refreshes *refreshStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req refreshRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil || strings.TrimSpace(req.RefreshToken) == "" {
			writeError(w, http.StatusBadRequest, "invalid_body", "refresh_token is required.")
			return
		}
		u, newRefresh, err := refreshes.rotate(req.RefreshToken)
		if err != nil {
			writeError(w, http.StatusUnauthorized, "invalid_refresh", err.Error())
			return
		}
		access, err := issuer.sign(u)
		if err != nil {
			writeError(w, http.StatusInternalServerError, "token_error", "Failed to issue access token.")
			return
		}
		writeJSON(w, http.StatusOK, tokenPair{
			User:         u,
			AccessToken:  access,
			RefreshToken: newRefresh,
			ExpiresIn:    int64(accessTokenTTL.Seconds()),
		})
	}
}

func issueTokens(issuer *jwtIssuer, refreshes *refreshStore, u user) (tokenPair, error) {
	access, err := issuer.sign(u)
	if err != nil {
		return tokenPair{}, err
	}
	refresh, err := refreshes.issue(u)
	if err != nil {
		return tokenPair{}, err
	}
	return tokenPair{
		User:         u,
		AccessToken:  access,
		RefreshToken: refresh,
		ExpiresIn:    int64(accessTokenTTL.Seconds()),
	}, nil
}

func signOutHandler(refreshes *refreshStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req refreshRequest
		_ = json.NewDecoder(r.Body).Decode(&req)
		if strings.TrimSpace(req.RefreshToken) != "" {
			refreshes.revoke(req.RefreshToken)
		}
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

func authMiddleware(issuer *jwtIssuer, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token, err := tokenFromHeader(r)
		if err != nil {
			writeError(w, http.StatusUnauthorized, "unauthenticated", err.Error())
			return
		}
		u, err := issuer.parse(token)
		if err != nil {
			writeError(w, http.StatusUnauthorized, "unauthenticated", "Access token is invalid or expired.")
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

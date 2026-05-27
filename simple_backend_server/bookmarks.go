package main

import (
	"encoding/json"
	"errors"
	"net/http"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/go-chi/chi/v5"
)

type bookmark struct {
	ID          string    `json:"id"`
	OwnerID     string    `json:"owner_id"`
	Title       string    `json:"title"`
	URL         string    `json:"url"`
	Description string    `json:"description"`
	Tags        []string  `json:"tags"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type bookmarkRequest struct {
	// Optional client-provided ID. When non-empty on POST, the server uses
	// it instead of generating one, so offline-first clients can mint stable
	// IDs locally. Ignored on PUT (path id wins).
	ID          string   `json:"id,omitempty"`
	Title       string   `json:"title"`
	URL         string   `json:"url"`
	Description string   `json:"description"`
	Tags        []string `json:"tags"`
}

type bookmarkStore struct {
	mu    sync.RWMutex
	items map[string]bookmark
}

func newBookmarkStore() *bookmarkStore {
	return &bookmarkStore{items: make(map[string]bookmark)}
}

func (s *bookmarkStore) listByOwner(ownerID string) []bookmark {
	s.mu.RLock()
	defer s.mu.RUnlock()
	out := make([]bookmark, 0)
	for _, b := range s.items {
		if b.OwnerID == ownerID {
			out = append(out, b)
		}
	}
	sort.Slice(out, func(i, j int) bool {
		return out[i].CreatedAt.After(out[j].CreatedAt)
	})
	return out
}

func (s *bookmarkStore) getOwned(id, ownerID string) (bookmark, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	b, ok := s.items[id]
	if !ok || b.OwnerID != ownerID {
		return bookmark{}, false
	}
	return b, true
}

// errBookmarkConflict is returned when a client-provided ID collides with an
// existing bookmark, so the handler can map it to HTTP 409.
var errBookmarkConflict = errors.New("bookmark with this id already exists")

func (s *bookmarkStore) create(ownerID string, req bookmarkRequest) (bookmark, error) {
	id := strings.TrimSpace(req.ID)
	if id == "" {
		generated, err := randomToken()
		if err != nil {
			return bookmark{}, err
		}
		id = generated
	}
	now := time.Now().UTC()
	b := bookmark{
		ID:          id,
		OwnerID:     ownerID,
		Title:       req.Title,
		URL:         req.URL,
		Description: req.Description,
		Tags:        normalizeTags(req.Tags),
		CreatedAt:   now,
		UpdatedAt:   now,
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, exists := s.items[id]; exists {
		return bookmark{}, errBookmarkConflict
	}
	s.items[id] = b
	return b, nil
}

func (s *bookmarkStore) update(id, ownerID string, req bookmarkRequest) (bookmark, bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	existing, ok := s.items[id]
	if !ok || existing.OwnerID != ownerID {
		return bookmark{}, false
	}
	existing.Title = req.Title
	existing.URL = req.URL
	existing.Description = req.Description
	existing.Tags = normalizeTags(req.Tags)
	existing.UpdatedAt = time.Now().UTC()
	s.items[id] = existing
	return existing, true
}

func (s *bookmarkStore) delete(id, ownerID string) bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	existing, ok := s.items[id]
	if !ok || existing.OwnerID != ownerID {
		return false
	}
	delete(s.items, id)
	return true
}

func normalizeTags(in []string) []string {
	if in == nil {
		return []string{}
	}
	seen := make(map[string]struct{}, len(in))
	out := make([]string, 0, len(in))
	for _, t := range in {
		t = strings.TrimSpace(t)
		if t == "" {
			continue
		}
		if _, dup := seen[t]; dup {
			continue
		}
		seen[t] = struct{}{}
		out = append(out, t)
	}
	return out
}

func validateBookmarkRequest(req bookmarkRequest) error {
	if strings.TrimSpace(req.Title) == "" {
		return errors.New("title is required")
	}
	if strings.TrimSpace(req.URL) == "" {
		return errors.New("url is required")
	}
	return nil
}

func registerBookmarkRoutes(r chi.Router, issuer *jwtIssuer, store *bookmarkStore) {
	r.Route("/api/bookmarks", func(r chi.Router) {
		r.Use(authMiddlewareChi(issuer))
		r.Get("/", listBookmarksHandler(store))
		r.Post("/", createBookmarkHandler(store))
		r.Get("/{id}", getBookmarkHandler(store))
		r.Put("/{id}", updateBookmarkHandler(store))
		r.Delete("/{id}", deleteBookmarkHandler(store))
	})
}

// authMiddlewareChi adapts the existing authMiddleware to chi's middleware
// signature so it can be applied to a route group.
func authMiddlewareChi(issuer *jwtIssuer) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authMiddleware(issuer, func(w http.ResponseWriter, r *http.Request) {
				next.ServeHTTP(w, r)
			})(w, r)
		})
	}
}

func listBookmarksHandler(store *bookmarkStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		u, _ := r.Context().Value(userCtxKey).(user)
		writeJSON(w, http.StatusOK, store.listByOwner(u.ID))
	}
}

func getBookmarkHandler(store *bookmarkStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		u, _ := r.Context().Value(userCtxKey).(user)
		id := chi.URLParam(r, "id")
		b, ok := store.getOwned(id, u.ID)
		if !ok {
			writeError(w, http.StatusNotFound, "not_found", "Bookmark not found.")
			return
		}
		writeJSON(w, http.StatusOK, b)
	}
}

func createBookmarkHandler(store *bookmarkStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		u, _ := r.Context().Value(userCtxKey).(user)
		var req bookmarkRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			writeError(w, http.StatusBadRequest, "invalid_body", "Request body is not valid JSON.")
			return
		}
		if err := validateBookmarkRequest(req); err != nil {
			writeError(w, http.StatusBadRequest, "invalid_input", err.Error())
			return
		}
		b, err := store.create(u.ID, req)
		if errors.Is(err, errBookmarkConflict) {
			writeError(w, http.StatusConflict, "conflict", "Bookmark with this id already exists.")
			return
		}
		if err != nil {
			writeError(w, http.StatusInternalServerError, "create_failed", "Failed to create bookmark.")
			return
		}
		writeJSON(w, http.StatusCreated, b)
	}
}

func updateBookmarkHandler(store *bookmarkStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		u, _ := r.Context().Value(userCtxKey).(user)
		id := chi.URLParam(r, "id")
		var req bookmarkRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			writeError(w, http.StatusBadRequest, "invalid_body", "Request body is not valid JSON.")
			return
		}
		if err := validateBookmarkRequest(req); err != nil {
			writeError(w, http.StatusBadRequest, "invalid_input", err.Error())
			return
		}
		b, ok := store.update(id, u.ID, req)
		if !ok {
			writeError(w, http.StatusNotFound, "not_found", "Bookmark not found.")
			return
		}
		writeJSON(w, http.StatusOK, b)
	}
}

func deleteBookmarkHandler(store *bookmarkStore) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		u, _ := r.Context().Value(userCtxKey).(user)
		id := chi.URLParam(r, "id")
		if !store.delete(id, u.ID) {
			writeError(w, http.StatusNotFound, "not_found", "Bookmark not found.")
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}
}

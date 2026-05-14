package metalhost

import (
	"net/http"
	"strings"
	"time"
)

const (
	DefaultUserAgent = "metalhost-sdk-go"
)

type Config struct {
	Endpoint   string
	APIKey     string
	HTTPClient *http.Client
	UserAgent  string
}

func (c Config) Client() *http.Client {
	if c.HTTPClient != nil {
		return c.HTTPClient
	}
	return &http.Client{Timeout: 30 * time.Second}
}

func (c Config) BaseURL() string {
	return strings.TrimRight(strings.TrimSpace(c.Endpoint), "/")
}

func (c Config) RoundTripper(base http.RoundTripper) http.RoundTripper {
	if base == nil {
		base = http.DefaultTransport
	}
	return authTransport{
		apiKey:    strings.TrimSpace(c.APIKey),
		userAgent: c.userAgent(),
		base:      base,
	}
}

func (c Config) userAgent() string {
	if ua := strings.TrimSpace(c.UserAgent); ua != "" {
		return ua
	}
	return DefaultUserAgent
}

type authTransport struct {
	apiKey    string
	userAgent string
	base      http.RoundTripper
}

func (t authTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	next := req.Clone(req.Context())
	if t.apiKey != "" {
		next.Header.Set("Authorization", "Bearer "+t.apiKey)
	}
	if t.userAgent != "" && next.Header.Get("User-Agent") == "" {
		next.Header.Set("User-Agent", t.userAgent)
	}
	return t.base.RoundTrip(next)
}

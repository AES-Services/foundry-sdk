package metalhost

import (
	"net/http"
	"testing"
)

type captureTransport struct {
	req *http.Request
}

func (t *captureTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	t.req = req
	return &http.Response{StatusCode: http.StatusOK, Body: http.NoBody}, nil
}

func TestConfigBaseURL(t *testing.T) {
	cfg := Config{Endpoint: " https://api.example.com/ "}
	if got := cfg.BaseURL(); got != "https://api.example.com" {
		t.Fatalf("BaseURL = %q", got)
	}
}

func TestRoundTripperAddsAuthAndUserAgent(t *testing.T) {
	capture := &captureTransport{}
	rt := Config{APIKey: "key-123"}.RoundTripper(capture)
	req, err := http.NewRequest(http.MethodGet, "https://api.example.com/healthz", nil)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := rt.RoundTrip(req); err != nil {
		t.Fatal(err)
	}
	if got := capture.req.Header.Get("Authorization"); got != "Bearer key-123" {
		t.Fatalf("Authorization = %q", got)
	}
	if got := capture.req.Header.Get("User-Agent"); got != DefaultUserAgent {
		t.Fatalf("User-Agent = %q", got)
	}
}

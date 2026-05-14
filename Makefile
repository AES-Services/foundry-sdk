BUF ?= $(shell go env GOPATH)/bin/buf
export PATH := $(shell go env GOPATH)/bin:$(PATH)

.PHONY: tools lint generate test ci openapi-public sync-docs

tools:
	go install github.com/bufbuild/buf/cmd/buf@v1.50.0
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.11
	go install connectrpc.com/connect/cmd/protoc-gen-connect-go@v1.19.1
	go install github.com/sudorandom/protoc-gen-connect-openapi@v0.25.5

lint:
	$(BUF) lint

generate:
	$(BUF) generate

test:
	go test ./...

ci: lint generate test

# Produce the customer-facing OpenAPI spec from the raw buf output:
#   - strip admin services (operator-only surface)
#   - add info / servers metadata for the rendered docs page
# Output: gen/openapi/metalhost.public.openapi.yaml
openapi-public: generate
	@command -v yq >/dev/null 2>&1 || { echo >&2 "yq is required (brew install yq or https://github.com/mikefarah/yq)"; exit 1; }
	yq eval ' \
	  .info = { \
	    "title": "Metalhost API", \
	    "version": "v1", \
	    "description": "Customer-facing HTTP API for Metalhost. Every dashboard action maps to one of the RPCs below. Authenticate with a Bearer API key on every request — mint one in the dashboard under Developers → API keys.\n\nEvery RPC is POST application/json with a Bearer header. Field names use snake_case (proto JSON).", \
	    "contact": {"name": "Metalhost support", "email": "support@metalhost.net", "url": "https://metalhost.net/docs"} \
	  } \
	  | .servers = [{"url": "https://api.metalhost.net", "description": "Production"}] \
	  | (.paths |= with_entries(select(.key | test("Admin[A-Z]") | not))) \
	  | (.tags  |= map(select(.name | test("Admin[A-Z]") | not))) \
	' gen/openapi/metalhost.openapi.yaml > gen/openapi/metalhost.public.openapi.yaml
	@echo "wrote gen/openapi/metalhost.public.openapi.yaml ($$(yq '.paths | length' gen/openapi/metalhost.public.openapi.yaml) paths)"

# Copy the public spec into the metalhost-web repo for the /docs/api viewer.
# Usage: make sync-docs DOCS=../metalhost-web
DOCS ?= ../metalhost-web
sync-docs: openapi-public
	@test -d "$(DOCS)/public" || { echo >&2 "$(DOCS)/public not found — set DOCS=path/to/metalhost-web"; exit 1; }
	cp gen/openapi/metalhost.public.openapi.yaml $(DOCS)/public/openapi.yaml
	@echo "synced openapi.yaml to $(DOCS)/public/openapi.yaml"

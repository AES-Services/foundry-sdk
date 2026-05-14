BUF ?= $(shell go env GOPATH)/bin/buf
export PATH := $(shell go env GOPATH)/bin:$(PATH)

.PHONY: tools lint generate test ci

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

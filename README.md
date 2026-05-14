# Metalhost SDK

Public customer SDK and API contract snapshots for AES Metalhost.

This repository is the customer-facing integration surface for Metalhost. It contains released public API snapshots, generated clients, and hand-written helpers used by the public `metalhost` CLI, Terraform provider, examples, and customer applications.

## Current Status

The Go SDK is published as the first public customer integration surface. It is already consumed by the public `metalhost` CLI and tracks released snapshots of the public API.

The current API surface is suitable for early customer/lab integration work. Production customer readiness still depends on the Metalhost service endpoint's infrastructure readiness, capacity checks, VM state reconciliation, persistent disk path, and billing settlement.

## Repository Contract

- This repo contains released snapshots of public `proto/aes/**` packages and generated OpenAPI.
- The checked-in proto snapshot is the public API contract for this SDK release.
- Generated SDK clients must be reproducible from the checked-in proto snapshot.
- Hand-written helpers must wrap generated clients without hiding server-side authorization, validation, or billing behavior.

## Layout

```text
proto/                 Released protobuf API snapshot
gen/go/                Generated Go protobuf + Connect clients
gen/openapi/           Generated OpenAPI specs
metalhost/               Hand-written Go SDK helpers
docs/                  SDK docs and release process notes
scripts/               Sync/generation scripts
```

## Go SDK

The Go module is:

```text
github.com/AES-Services/metalhost-sdk
```

Generated clients live under:

```text
github.com/AES-Services/metalhost-sdk/gen/go/aes/...
```

Hand-written helpers live under:

```text
github.com/AES-Services/metalhost-sdk/metalhost
```

## Generate

Install local protobuf plugins:

```sh
make tools
```

Then run:

```sh
make ci
```

## Sync API Snapshot

From this repo:

```sh
METALHOST_API_SOURCE="/path/to/api/source" ./scripts/sync-api-snapshot.sh
```

The script replaces `proto/aes`, regenerates Go/OpenAPI outputs, and runs `go mod tidy`.

## Release Rule

No customer-facing Metalhost API change is complete until this SDK repo has:

- updated proto snapshot,
- regenerated clients/OpenAPI,
- passing CI,
- release notes documenting breaking changes or new features.

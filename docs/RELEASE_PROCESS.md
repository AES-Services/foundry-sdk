# Release Process

Metalhost SDK releases publish a customer-facing API snapshot and generated clients.

## Release Checklist

1. Sync the API snapshot.

   ```sh
   METALHOST_API_SOURCE="/path/to/api/source" ./scripts/sync-api-snapshot.sh
   ```

2. Review generated changes under `proto/`, `gen/go/`, and `gen/openapi/`.
3. Update release notes with new APIs, behavior changes, and any breaking changes.
4. Run:

   ```sh
   buf lint
   buf generate
   go test ./...
   ```

5. Tag the release:

   ```sh
   git tag v0.1.0
   git push origin v0.1.0
   ```

## Compatibility

The SDK should support the current Metalhost API release and the previous minor release where practical.

Generated clients may expose new fields immediately. Hand-written helpers should remain backwards-compatible unless the API release itself is intentionally breaking.

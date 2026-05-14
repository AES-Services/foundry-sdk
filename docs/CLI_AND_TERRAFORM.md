# CLI And Terraform Consumers

The public `metalhost` CLI and Terraform provider should consume the released public SDK/API contract from this repository.

## Public CLI

The public CLI should use generated Go clients plus hand-written SDK helpers for:

- auth headers,
- pagination,
- operation waiting,
- idempotency keys,
- typed errors,
- presigned upload/download workflows.

## Terraform Provider

The Terraform provider should use the same generated clients for API calls, but should keep Terraform-specific diff/state behavior inside the provider.

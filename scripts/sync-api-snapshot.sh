#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$(go env GOPATH)/bin:${PATH}"
API_SOURCE="${METALHOST_API_SOURCE:-}"

if [[ -z "${API_SOURCE}" ]]; then
  echo "METALHOST_API_SOURCE is required" >&2
  exit 2
fi

if [[ ! -d "${API_SOURCE}/proto/aes" ]]; then
  echo "missing proto tree: ${API_SOURCE}/proto/aes" >&2
  exit 2
fi

rm -rf "${ROOT}/proto/aes" "${ROOT}/gen/go" "${ROOT}/gen/openapi"
mkdir -p "${ROOT}/proto/aes" "${ROOT}/gen"

for pkg in \
  audit \
  baremetal \
  catalog \
  compute \
  health \
  iam \
  network \
  objectstore \
  ops \
  project \
  quota \
  storage \
  support \
  wallet \
  webhooks
do
  if [[ -d "${API_SOURCE}/proto/aes/${pkg}" ]]; then
    cp -R "${API_SOURCE}/proto/aes/${pkg}" "${ROOT}/proto/aes/${pkg}"
  fi
done

cd "${ROOT}"
buf lint
buf generate
go mod tidy
go test ./...

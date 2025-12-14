#!/usr/bin/env bash
set -euo pipefail

# Bring up the stack and ensure DB is prepared.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

COMPOSE_CMD="${COMPOSE_CMD:-docker compose}"
BUILD_FLAG=""

if [[ "${1:-}" == "--build" ]]; then
  BUILD_FLAG="--build"
fi

echo "Starting containers (${COMPOSE_CMD} up -d ${BUILD_FLAG})..."
${COMPOSE_CMD} up -d ${BUILD_FLAG}

echo "Preparing database..."
${COMPOSE_CMD} run --rm web ./bin/rails db:prepare

echo "Stack is up. Web: http://localhost:3000"

#!/usr/bin/env bash
set -euo pipefail

# Stop the stack, optionally removing volumes with --volumes
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

COMPOSE_CMD="${COMPOSE_CMD:-docker compose}"

if [ "$#" -eq 0 ]; then
  echo "Stopping containers (${COMPOSE_CMD} down)..."
  ${COMPOSE_CMD} down
else
  echo "Stopping containers (${COMPOSE_CMD} down $*)..."
  ${COMPOSE_CMD} down "$@"
fi

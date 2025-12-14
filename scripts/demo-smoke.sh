#!/usr/bin/env bash
set -euo pipefail

# Simple smoke test: start stack, run migrations, mint agent/JWT, send a test event, and report alerts.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

COMPOSE_CMD="${COMPOSE_CMD:-docker compose}"
WEB_URL="${WEB_URL:-http://localhost:3000}"

echo "==> Bringing up containers (web, worker, db, redis)..."
${COMPOSE_CMD} up -d

echo "==> Waiting for web to respond..."
for i in {1..30}; do
  if curl -fs "${WEB_URL}/up" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo "==> Ensuring database is prepared..."
${COMPOSE_CMD} run --rm web ./bin/rails db:prepare

echo "==> Minting a fresh agent + JWT..."
creds="$(${COMPOSE_CMD} run --rm web bundle exec rails runner "agent,token = Agent.create_with_token!(name: 'smoke-test'); jwt = AuthToken.issue(agent: agent, api_token: token); puts \"AGENT_ID=#{agent.id}\nJWT=#{jwt}\"")"
eval "$creds"
echo "    Using agent_id=${AGENT_ID}"

echo "==> Sending test event (powershell -enc ... should trigger an alert)..."
now_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
curl -s -X POST "${WEB_URL}/api/v1/events" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${JWT}" \
  -d "{\"agent_id\": ${AGENT_ID}, \"event_type\": \"process_create\", \"timestamp\": \"${now_utc}\", \"host\": \"demo-host\", \"process_name\": \"powershell.exe\", \"command_line\": \"powershell -enc ZQB2AGkAbA\"}"
echo

echo "==> Waiting briefly for Sidekiq to process..."
sleep 2

alert_report="$(${COMPOSE_CMD} run --rm web bundle exec rails runner "puts \"events=#{Event.count}, alerts=#{Alert.count}\"")"
echo "==> ${alert_report}"

cat <<EOF
Smoke test complete.
- Dashboard: ${WEB_URL}
- Alerts list: ${WEB_URL}/ui/alerts
- Agent ID used: ${AGENT_ID}
- JWT used: ${JWT}
EOF

# Security Event Ingestion & Detection Platform (Rails API)
Containerized Rails API that ingests security telemetry, analyzes it asynchronously with rule-based detections, and emits alerts. Everything runs via Docker Compose (Rails API, Sidekiq, Postgres, Redis).

## Quickstart (Docker)

1. Ensure Docker is running.
2. Update `.env.development` if needed (set `JWT_SECRET`, database passwords, etc.).
3. Start the stack (and prepare DB) with helper script:
   ```bash
   chmod +x scripts/dev-up.sh scripts/dev-down.sh  # once
   ./scripts/dev-up.sh --build   # omit --build for faster restarts
   ```
4. Seed the database (prints demo agent tokens/JWTs):
   ```bash
   docker compose run --rm web ./bin/rails db:seed
   ```
5. Run the test suite (RSpec inside the container):
   ```bash
   docker compose run --rm web bundle exec rspec
   ```
6. Stop the stack:
   ```bash
   ./scripts/dev-down.sh             # stop containers
   ./scripts/dev-down.sh --volumes   # stop and wipe data
   ```

## Minimal Hotwire UI (demo)
- Open `http://localhost:3000` to view the dashboard (alerts list, recent events).
- Inline resolve/re-open uses Turbo frames; no JS build step (Turbo loaded via CDN).
- “All Alerts” view at `/ui/alerts` shows the latest 100 alerts.

Services:
- `web`: Rails API (port `3000`).
- `worker`: Sidekiq for async detections.
- `db`: Postgres 16.
- `redis`: Redis 7 for Sidekiq + throttling cache.

## Authentication

Agents authenticate with JWT bearer tokens signed using `JWT_SECRET`. Each JWT embeds:
- `agent_id`
- `api_token` (hashed and stored as `api_token_digest`)
- `exp` (15-minute default)

Seed output shows demo credentials. To mint a new agent + JWT:
```ruby
agent, api_token = Agent.create_with_token!(name: "New Agent")
jwt = AuthToken.issue(agent: agent, api_token: api_token)
```

## API

### POST /api/v1/events
Required fields: `agent_id`, `event_type`, `timestamp`, `host`  
Optional: `process_name`, `command_line`, `username`, `parent_process_name`, `metadata` (JSON)

Example:
```bash
curl -X POST http://localhost:3000/api/v1/events \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_FROM_SEEDS>" \
  -d '{
    "agent_id": 1,
    "event_type": "process_create",
    "timestamp": "2025-01-01T12:00:00Z",
    "host": "host-1",
    "process_name": "powershell.exe",
    "command_line": "powershell -enc ZQB2AGkAbA",
    "username": "alice",
    "metadata": {"source": "demo"}
  }'
```
Returns `202 Accepted` with `{ "status": "accepted", "event_id": <id> }`.

## Detection Rules (async via Sidekiq)

- Encoded PowerShell execution (`powershell` + `-enc`/`-encodedcommand`) → `high`
- Suspicious LOLBins (`rundll32`, `mshta`, `certutil`, `regsvr32`, `wmic`, `installutil`) → `medium`
- Excessive auth failures (>=5 in 10 minutes for same user/host) → `medium`
- Abnormal process ancestry (Office spawning shells, cmd -> powershell chains) → `high`

Alerts include severity, reason, related event ID, status, and deduplication keys (10-minute window by default).

## Rate Limiting

Rack::Attack throttles:
- 100 req/min per IP for `/api/*`
- 60 req/min per IP for `/api/v1/events`

Responds with HTTP 429 and `{ "error": "rate_limited" }`.

## Environment

- Ruby `3.4.7`, Rails `8.1.1`
- Postgres + Redis in Docker
- Sidekiq queue config: `config/sidekiq.yml`
- Env vars: `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`, `RAILS_ENV`, `RAILS_LOG_TO_STDOUT`

## Running in Production Mode

Build with dev/test gems excluded:
```bash
docker build --build-arg BUNDLE_WITHOUT="development:test" -t security-api .
```
Provide production env vars at runtime (including `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`).

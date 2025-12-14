class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Global throttle for API access to prevent abuse
  throttle("req/ip", limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # Stricter throttle for ingestion endpoint
  throttle("events/ip", limit: 60, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/events" && req.post?
  end

  self.throttled_responder = lambda do |request|
    body = { error: "rate_limited" }.to_json
    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => request.env["rack.attack.match_data"][:period].to_s
    }
    [429, headers, [body]]
  end
end

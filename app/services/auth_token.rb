class AuthToken
  ALGORITHM = "HS256".freeze

  def self.issue(agent:, api_token:, exp: 15.minutes.from_now)
    encode(agent_id: agent.id, api_token: api_token, exp: exp.to_i)
  end

  def self.encode(payload)
    JWT.encode(payload, secret, ALGORITHM)
  end

  def self.decode(token)
    decoded, = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
    decoded
  end

  def self.secret
    ENV.fetch("JWT_SECRET", "dev-secret-change-me")
  end
end

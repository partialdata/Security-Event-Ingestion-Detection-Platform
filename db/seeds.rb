puts "Seeding demo agents..."

[
  "Demo Agent 1",
  "Demo Agent 2"
].each do |name|
  if Agent.exists?(name: name)
    puts "Agent #{name} already exists (token not regenerated)"
    next
  end

  agent, token = Agent.create_with_token!(name: name)
  jwt = AuthToken.issue(agent: agent, api_token: token)

  puts "Created agent #{agent.name} (id=#{agent.id})"
  puts "  API token: #{token}"
  puts "  JWT: #{jwt}"
end

require "rails_helper"

RSpec.describe Agent, type: :model do
  it "authenticates with the correct token" do
    agent, token = Agent.create_with_token!(name: "Auth Agent")

    expect(agent.authenticate_token(token)).to eq(true)
    expect(agent.authenticate_token("wrong")).to eq(false)
  end
end

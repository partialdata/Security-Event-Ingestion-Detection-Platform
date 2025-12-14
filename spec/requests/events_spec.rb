require "rails_helper"

RSpec.describe "Event ingestion", type: :request do
  let!(:agent_pair) { Agent.create_with_token!(name: "Spec Agent") }
  let(:agent) { agent_pair.first }
  let(:api_token) { agent_pair.last }
  let(:jwt) { AuthToken.issue(agent: agent, api_token: api_token) }
  let(:headers) { { "Authorization" => "Bearer #{jwt}" } }
  let(:payload) do
    {
      agent_id: agent.id,
      event_type: "process_create",
      timestamp: Time.current.iso8601,
      host: "host-1",
      process_name: "powershell.exe",
      command_line: "powershell -enc aGVsbG8=",
      username: "demo",
      metadata: { source: "rspec" }
    }
  end

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it "ingests events and enqueues analysis" do
    expect do
      post "/api/v1/events", params: payload, headers: headers
    end.to change(Event, :count).by(1)

    expect(response).to have_http_status(:accepted)
    expect(EventAnalysisJob).to have_been_enqueued.with(Event.last.id)
  end

  it "rejects requests without authentication" do
    post "/api/v1/events", params: payload
    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects disabled agents" do
    agent.update!(status: :disabled)
    post "/api/v1/events", params: payload, headers: headers
    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects mismatched agent IDs" do
    post "/api/v1/events", params: payload.merge(agent_id: agent.id + 1), headers: headers
    expect(response).to have_http_status(:unauthorized)
  end
end

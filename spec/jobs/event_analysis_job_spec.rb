require "rails_helper"

RSpec.describe EventAnalysisJob, type: :job do
  let(:agent) { create(:agent) }
  let(:event) do
    create(
      :event,
      agent: agent,
      host: "host-1",
      payload: {
        process_name: "powershell.exe",
        command_line: "powershell -enc ZQB2AGkAbA"
      }
    )
  end

  it "creates alerts for matching detection rules" do
    expect { described_class.perform_now(event.id) }.to change(Alert, :count).by(1)
    alert = Alert.last
    expect(alert.severity).to eq("high")
    expect(alert.reason).to include("PowerShell")
  end

  it "deduplicates within the window" do
    described_class.perform_now(event.id)
    expect { described_class.perform_now(event.id) }.not_to change(Alert, :count)
  end
end

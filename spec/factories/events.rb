FactoryBot.define do
  factory :event do
    association :agent
    event_type { "process_create" }
    host { "host.example" }
    occurred_at { Time.current }
    payload do
      {
        process_name: "powershell.exe",
        command_line: "powershell -enc ZQB2AGkAbA"
      }
    end
  end
end

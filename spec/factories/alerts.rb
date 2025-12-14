FactoryBot.define do
  factory :alert do
    association :event
    agent { event.agent }
    severity { "medium" }
    reason { "Test alert" }
    status { "open" }
    dedup_key { SecureRandom.hex(8) }
  end
end

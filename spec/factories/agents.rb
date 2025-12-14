FactoryBot.define do
  factory :agent do
    sequence(:name) { |n| "Agent #{n}" }
    api_token { "token-#{SecureRandom.hex(4)}" }
    status { :enabled }
  end
end

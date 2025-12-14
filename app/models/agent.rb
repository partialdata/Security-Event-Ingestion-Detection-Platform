class Agent < ApplicationRecord
  has_secure_password :api_token, validations: false

  has_many :events, dependent: :destroy
  has_many :alerts, dependent: :destroy

  enum :status, { enabled: 0, disabled: 1 }

  validates :name, presence: true
  validates :api_token_digest, presence: true

  def authenticate_token(token)
    enabled? && !!authenticate_api_token(token)
  end

  def self.create_with_token!(name:)
    token = SecureRandom.hex(24)
    agent = create!(name: name, status: :enabled, api_token: token)
    [agent, token]
  end
end

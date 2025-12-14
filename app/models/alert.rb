class Alert < ApplicationRecord
  SEVERITIES = %w[low medium high].freeze

  belongs_to :event
  belongs_to :agent

  enum :status, { open: "open", resolved: "resolved" }

  validates :severity, inclusion: { in: SEVERITIES }
  validates :reason, :dedup_key, :status, presence: true

  scope :recent_with_key, ->(key, window:) { where(dedup_key: key).where("created_at >= ?", window.ago) }
end

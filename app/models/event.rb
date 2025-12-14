class Event < ApplicationRecord
  belongs_to :agent
  has_many :alerts, dependent: :destroy

  validates :event_type, :host, :occurred_at, presence: true
  validate :payload_is_hash

  after_create_commit :enqueue_analysis

  def normalized_payload
    payload.with_indifferent_access
  end

  private

  def enqueue_analysis
    EventAnalysisJob.perform_later(id)
  end

  def payload_is_hash
    errors.add(:payload, "must be a Hash") unless payload.is_a?(Hash)
  end
end

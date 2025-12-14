class EventAnalysisJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.includes(:agent).find_by(id: event_id)
    return unless event

    Detection::RuleRunner.new(event).call.each do |result|
      dedup_key = result.respond_to?(:dedup_key) ? result.dedup_key : result[:dedup_key]
      window = if result.respond_to?(:dedup_window)
                 result.dedup_window
               else
                 result[:dedup_window]
               end
      window ||= 10.minutes
      next if Alert.recent_with_key(dedup_key, window: window).exists?

      Alert.create!(
        event: event,
        agent: event.agent,
        severity: result.respond_to?(:severity) ? result.severity : result[:severity],
        reason: result.respond_to?(:reason) ? result.reason : result[:reason],
        status: "open",
        dedup_key: dedup_key
      )
    end
  end
end

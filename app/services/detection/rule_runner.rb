module Detection
  RuleResult = Struct.new(:severity, :reason, :dedup_key, :dedup_window, keyword_init: true)

  class RuleRunner
    def initialize(event)
      @event = event
    end

    def call
      rules.flat_map do |rule|
        outcome = rule.call(@event)
        next [] if outcome.nil?
        outcome.is_a?(Array) ? outcome.compact : [outcome]
      end
    end

    private

    def rules
      @rules ||= [
        Detection::Rules::EncodedPowerShell.new,
        Detection::Rules::LolbinUsage.new,
        Detection::Rules::ExcessiveAuthFailures.new,
        Detection::Rules::AbnormalProcessAncestry.new
      ]
    end
  end
end

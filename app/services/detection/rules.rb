module Detection
  module Rules
    class BaseRule
      private

      def result(event:, severity:, reason:, dedup_key:, dedup_window: 10.minutes)
        RuleResult.new(
          severity: severity,
          reason: reason,
          dedup_key: dedup_key,
          dedup_window: dedup_window
        )
      end
    end

    class EncodedPowerShell < BaseRule
      def call(event)
        command = event.payload["command_line"].to_s.downcase
        return if command.empty?
        return unless command.include?("powershell") && (command.include?("-enc") || command.include?("-encodedcommand"))

        result(
          event: event,
          severity: "high",
          reason: "Encoded PowerShell execution detected",
          dedup_key: "encoded_psh:#{event.agent_id}:#{event.host}"
        )
      end
    end

    class LolbinUsage < BaseRule
      LOLBINS = %w[rundll32.exe regsvr32.exe mshta.exe certutil.exe wmic.exe installutil.exe].freeze

      def call(event)
        command = event.payload["command_line"].to_s.downcase
        return if command.empty?

        if LOLBINS.any? { |bin| command.include?(bin) }
          result(
            event: event,
            severity: "medium",
            reason: "Suspicious LOLBin usage",
            dedup_key: "lolbin:#{event.agent_id}:#{event.host}:#{matched_bin(command)}"
          )
        end
      end

      private

      def matched_bin(command)
        LOLBINS.find { |bin| command.include?(bin) }
      end
    end

    class ExcessiveAuthFailures < BaseRule
      WINDOW = 10.minutes
      THRESHOLD = 5

      def call(event)
        return unless event.event_type == "auth_failure"

        username = event.payload["username"]
        return unless username

        recent_failures = Event.where(event_type: "auth_failure", host: event.host)
                               .where("payload ->> 'username' = ?", username)
                               .where("occurred_at >= ?", WINDOW.ago)
                               .count

        return unless recent_failures >= THRESHOLD

        result(
          event: event,
          severity: "medium",
          reason: "Excessive authentication failures for #{username} on #{event.host}",
          dedup_key: "auth_failures:#{event.agent_id}:#{event.host}:#{username}",
          dedup_window: WINDOW
        )
      end
    end

    class AbnormalProcessAncestry < BaseRule
      OFFICE_PROCS = %w[winword.exe excel.exe outlook.exe].freeze

      def call(event)
        parent = event.payload["parent_process_name"].to_s.downcase
        child = event.payload["process_name"].to_s.downcase
        command = event.payload["command_line"].to_s.downcase
        return if parent.empty? || child.empty?

        if OFFICE_PROCS.include?(parent) && (child.include?("cmd") || child.include?("powershell"))
          result(
            event: event,
            severity: "high",
            reason: "Office spawned shell process (#{parent} -> #{child})",
            dedup_key: "parent_child:#{event.agent_id}:#{event.host}:#{parent}:#{child}"
          )
        elsif command.include?("cmd.exe /c powershell") || command.include?("cmd /c powershell")
          result(
            event: event,
            severity: "medium",
            reason: "Chained command execution detected (cmd -> powershell)",
            dedup_key: "cmd_powershell:#{event.agent_id}:#{event.host}"
          )
        end
      end
    end
  end
end

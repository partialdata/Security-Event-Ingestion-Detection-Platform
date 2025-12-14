module Api
  module V1
    class EventsController < Api::BaseController
      def create
        raise AuthenticationError unless current_agent.enabled?
        raise AuthenticationError unless current_agent.id == event_params[:agent_id].to_i

        event = current_agent.events.create!(
          event_type: event_params[:event_type],
          host: event_params[:host],
          occurred_at: parsed_timestamp,
          payload: build_payload(event_params)
        )

        render json: { status: "accepted", event_id: event.id }, status: :accepted
      end

      private

      def event_params
        params.permit(:agent_id, :event_type, :timestamp, :host, :process_name, :command_line, :username, :parent_process_name, metadata: {})
      end

      def parsed_timestamp
        Time.zone.parse(event_params[:timestamp].to_s)
      rescue ArgumentError
        raise ActionController::ParameterMissing, "Invalid timestamp"
      end

      def build_payload(permitted_params)
        {
          process_name: permitted_params[:process_name],
          command_line: permitted_params[:command_line],
          username: permitted_params[:username],
          parent_process_name: permitted_params[:parent_process_name],
          metadata: permitted_params[:metadata]
        }.compact
      end
    end
  end
end

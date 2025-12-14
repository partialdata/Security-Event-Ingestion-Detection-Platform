class Api::BaseController < ActionController::API
  class AuthenticationError < StandardError; end

  rescue_from AuthenticationError, with: :render_unauthorized
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  before_action :authenticate_agent!

  attr_reader :current_agent

  private

  def authenticate_agent!
    header = request.headers["Authorization"]
    token = header.split(" ").last if header.present?
    raise AuthenticationError unless token

    payload = AuthToken.decode(token)
    agent = Agent.find_by(id: payload["agent_id"])
    raise AuthenticationError unless agent&.authenticate_token(payload["api_token"])

    @current_agent = agent
  rescue JWT::DecodeError, JWT::VerificationError
    raise AuthenticationError
  end

  def render_unauthorized
    render json: { error: "unauthorized" }, status: :unauthorized
  end

  def render_unprocessable(exception)
    render json: { error: "invalid_request", details: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_bad_request(exception)
    render json: { error: "bad_request", details: exception.message }, status: :bad_request
  end
end

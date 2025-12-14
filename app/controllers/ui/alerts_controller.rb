module Ui
  class AlertsController < ApplicationController
    before_action :set_alert, only: :update

    def index
      @alerts = Alert.includes(:event, :agent).order(created_at: :desc).limit(100)
    end

    def update
      @alert.update!(status: params[:status])

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(view_context.dom_id(@alert), partial: "ui/alerts/alert", locals: { alert: @alert }) }
        format.html { redirect_back fallback_location: ui_alerts_path, notice: "Updated alert" }
      end
    end

    private

    def set_alert
      @alert = Alert.find(params[:id])
    end
  end
end

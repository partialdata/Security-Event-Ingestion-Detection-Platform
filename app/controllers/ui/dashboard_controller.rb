module Ui
  class DashboardController < ApplicationController
    def index
      @open_count = Alert.where(status: "open").count
      @recent_alerts = Alert.includes(:event, :agent).order(created_at: :desc).limit(50)
      @recent_events = Event.includes(:agent).order(created_at: :desc).limit(10)
    end
  end
end

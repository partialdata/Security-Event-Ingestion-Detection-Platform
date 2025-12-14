class ApplicationController < ActionController::Base
  layout "ui"
  protect_from_forgery with: :exception
end

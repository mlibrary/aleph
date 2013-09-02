class HomeController < ApplicationController
  def index
    url = Rails.application.config.main_service_url
    redirect_to url unless url.blank?
  end
end

class HomeController < ApplicationController
  def index
    redirect_to edit_user_registration_path
    #url = Rails.application.config.main_service_url
    #redirect_to url unless url.blank?
  end
end

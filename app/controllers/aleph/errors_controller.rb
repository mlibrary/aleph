class Aleph::ErrorsController < ApplicationController
  
  def catch
    user = current_user || current_ill_user
    logger.error "Aleph login error #{params[:code]} caught. User: #{user.inspect}"
  end

end

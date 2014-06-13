class IllUsers::RegistrationsController < Devise::RegistrationsController
  
  def show
    authenticate_scope!
    expires_now
  end
end

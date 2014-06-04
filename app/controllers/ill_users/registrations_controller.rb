class IllUsers::RegistrationsController < Devise::RegistrationsController
  
  def show
    authenticate_scope!
  end
end

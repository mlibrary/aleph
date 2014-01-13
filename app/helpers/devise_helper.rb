module DeviseHelper
  def devise_error_messages!
    if controller.devise_controller?
      return if resource.errors.empty?
      flash[:error] = Array.new
      flash[:error].concat resource.errors.full_messages
    end
  end
end

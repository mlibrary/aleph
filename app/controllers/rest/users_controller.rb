class Rest::UsersController < ApplicationController
  def show
    @user = User.find_by_id(params[:id])
    @expanded_user = @user.expand
    respond_to do |format|
      format.json { render :json => @expanded_user }
    end
  end
end

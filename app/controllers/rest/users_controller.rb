class Rest::UsersController < ApplicationController
  def show
    @user = User.find_by_id(params[:id])
    @expanded_user = @user.expand
    respond_to do |format|
      format.json { render :json => @expanded_user }
      format.text { render :text => @user.id }
    end
  end

  def dtu
    uid = params[:id]
    identity = Identity.where(:provider => 'dtu', :uid => uid).first
    if identity.nil?
      info = DtuBase.lookup(:cwis => uid)
      User.create_from_dtubase_info(info)
    else
      params[:id] = identity.user.id
    end
    show
  end

end

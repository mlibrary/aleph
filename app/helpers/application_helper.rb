module ApplicationHelper
  def render_edit_for_user_type
    if @user.dtu_affiliate?
      render :partial => 'edit_dtu_user'
    else
      render :partial => 'edit_normal_user'
   end
  end
end

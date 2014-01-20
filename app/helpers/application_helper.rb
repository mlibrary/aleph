module ApplicationHelper
  def render_edit_for_user_type
    if @user.dtu_affiliate?
      render :partial => 'edit_dtu_user'
    elsif @user.library?
      render :partial => 'edit_library'
    else
      render :partial => 'edit_normal_user'
   end
  end
end

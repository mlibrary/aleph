ActiveAdmin.register User do
  menu :priority => 1
  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  member_action :update_address, :method => :get do
    user = User.find(params[:id])
    #user.address_from_cpr
    logger.info "Update admin address"
    redirect_to admin_user_path
  end

  action_item :only => :show do
    link_to I18n.t('riyosha.edit.update_address'),
      update_address_admin_user_path
  end

end

ActiveAdmin.register IllUser do
  menu :priority => 2
  actions :all, :except => [:new, :destroy]

  index do
    column 'Library Id' do |user|
      link_to user.library_id, admin_ill_user_path(user)
    end
    column :name
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
  end

  filter :library_id, :label => 'Library Id'
  filter :name
  filter :email

  show do |ill_user|
    default_main_content

    panel "Address" do
      ill_user.address_lines
    end

    panel "Aleph data" do
      formatted_aleph_data(ill_user).html_safe
    end

  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :name, :input_html => { :disabled => true }
      f.input :email, :input_html => { :disabled => true }
      f.input :password
      f.input :password_confirmation
      f.input :user_type, :input_html => { :disabled => true }
      f.input :user_sub_type, :input_html => { :disabled => true }
    end

    f.actions
  end

  member_action :update_aleph, :method => :get do
    user = IllUser.find(params[:id])
    begin
      user.aleph_borrower
    rescue Aleph::Error
      flash[:error] = e.message
    end
    redirect_to admin_user_path
  end

  action_item :only => :show do
    link_to I18n.t('riyosha.edit.aleph'),
      update_aleph_admin_user_path
  end

end

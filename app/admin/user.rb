ActiveAdmin.register User do
  menu :priority => 1
  actions :all, :except => [:destroy]

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
      f.input :first_name
      f.input :last_name
      f.input :password
      f.input :password_confirmation
      f.input :user_type
      f.input :user_sub_type
    end
    f.has_many :address, :new_record => false do |a|
      a.inputs I18n.t('riyosha.admin.user.address') do
        a.input :line1
        a.input :line2
        a.input :line3
        a.input :line4
        a.input :line5
        a.input :line6
        a.input :zipcode
        a.input :cityname
        a.input :country, :as => :string
      end
    end
    f.actions
  end

  member_action :update_address, :method => :get do
    user = User.find(params[:id])
    user.address_from_cpr
    redirect_to admin_user_path
  end

  action_item :only => :show do
    link_to I18n.t('riyosha.edit.update_address'),
      update_address_admin_user_path
  end

  member_action :update_aleph, :method => :get do
    user = User.find(params[:id])
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

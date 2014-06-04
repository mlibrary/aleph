ActiveAdmin.register IllUser do
  menu :priority => 2
  actions :all, :except => [:new, :destroy]

  index do
    column 'Library Id' do |user|
      link_to user.library_id, edit_admin_ill_user_path(user)
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

  form do |f|
    f.inputs "Admin Details" do
      f.input :name, :input_html => { :disabled => true }
      f.input :email, :input_html => { :disabled => true }
      f.input :password
      f.input :password_confirmation
      f.input :user_type, :input_html => { :disabled => true }
      f.input :user_sub_type, :input_html => { :disabled => true }
    end
    f.has_many :address, :new_record => false do |a|
      a.inputs I18n.t('riyosha.admin.user.address') do
        a.input :line1, :input_html => { :disabled => true }
        a.input :line2, :input_html => { :disabled => true }
        a.input :line3, :input_html => { :disabled => true }
        a.input :line4, :input_html => { :disabled => true }
        a.input :line5, :input_html => { :disabled => true }
        a.input :line6, :input_html => { :disabled => true }
        a.input :zipcode, :input_html => { :disabled => true }
        a.input :cityname, :input_html => { :disabled => true }
        a.input :country, :as => :string, :input_html => { :disabled => true }
      end
    end
    f.actions
  end

  #member_action :update_address, :method => :get do
  #  user = User.find(params[:id])
  #  user.address_from_cpr
  #  redirect_to admin_user_path
  #end

  #action_item :only => :show do
  #  link_to I18n.t('riyosha.edit.update_address'),
  #    update_address_admin_user_path
  #end

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

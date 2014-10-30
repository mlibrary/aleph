# -*- coding: utf-8 -*-
ActiveAdmin.register User do

  menu :priority => 1
  actions :all, :except => [:new, :destroy]

  index do
    column 'Email' do |user|
      link_to user.email, admin_user_path(user)
    end
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
  end

  filter :email

  show do |user|
    default_main_content

    user.expand
    panel "Address" do
      user.address_lines
    end

    panel "Identities" do
      user.identities
    end

    panel "Nemid" do
      user.dk_nemid_users
    end

    # f.has_many :address, :new_record => false, :heading => false do |a|
    #   a.inputs 'Address' do
    #     a.input :line1, :input_html => { :disabled => true }
    #     a.input :line2, :input_html => { :disabled => true }
    #     a.input :line3, :input_html => { :disabled => true }
    #     a.input :line4, :input_html => { :disabled => true }
    #     a.input :line5, :input_html => { :disabled => true }
    #     a.input :line6, :input_html => { :disabled => true }
    #     a.input :zipcode, :input_html => { :disabled => true }
    #     a.input :cityname, :input_html => { :disabled => true }
    #     a.input :country, :as => :string, :input_html => { :disabled => true }
    #   end
    # end
    # f.has_many :identities, :new_record => false, :heading => false do |i|
    #   i.inputs 'Identity' do
    #     i.input :id, :input_html => { :disabled => true }
    #     i.input :provider, :input_html => { :disabled => true }
    #     i.input :uid, :input_html => { :disabled => true }
    #   end
    # end
    # f.has_many :dk_nemid_users, :new_record => false, :heading => false do |i|
    #   i.inputs 'DkNemidUser' do
    #     i.input :id, :input_html => { :disabled => true }
    #     i.input :identifier, :input_html => { :disabled => true }
    #     i.input :cpr, :input_html => { :disabled => true }
    #     i.input :created_at, :input_html => { :disabled => true }
    #     i.input :updated_at, :input_html => { :disabled => true }
    #   end
    # end


    panel "Aleph data" do
      formatted_aleph_data(user).html_safe
    end
    panel "DTUbase data" do
      formatted_dtubase_data(user).html_safe if user.dtu_affiliate?
    end
  end

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
    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end
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

  action_item :only => [:show] do
    link_to I18n.t('riyosha.edit.aleph'),
      update_aleph_admin_user_path
  end

end

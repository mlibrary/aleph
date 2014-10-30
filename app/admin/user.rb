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

  action_item :only => [:show], :if => proc { user.may_lend_printed? } do
    link_to I18n.t('riyosha.edit.aleph'), update_aleph_admin_user_path
  end

  member_action :remove_nemid, :method => :get do
    user = User.find(params[:id])
    user.dk_nemid_users = []
    user.save
    redirect_to admin_user_path
  end

  action_item :only => :show, :if => proc { !user.dk_nemid_users.blank? } do
    link_to I18n.t('riyosha.edit.remove_nemid'), remove_nemid_admin_user_path, :confirm => 'Are you sure?'
  end

end

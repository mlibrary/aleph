Riyosha::Application.routes.draw do
  get "home/index"
  root :to => 'home#index'

  devise_for :users,
    :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks",
      :sessions => "users/sessions",
      :registrations => "users/registrations",
      :confirmations => "users/confirmations",
    },
    :path => '/users',
    :path_names => {:sign_in => 'login', :sign_out => 'logout'}
  devise_scope :user do
    get "users/:id/update_address", :to => "users/registrations#update_address",
      :as => "user_update_address"
    get "users/library", :to => "users/registrations#new_library", :as =>
      "user_new_library"
    get "users/mail", :to => "users/confirmations#wait_mail", :as =>
      "user_wait_mail"
    get "users/confirmed", :to => "users/confirmations#confirmed", :as =>
      "user_confirmed"
  end

  devise_for :dk_nemid_users,
    :scope => 'dk_nemid',
    :controllers => { :dk_nemid_sessions => "users/nemid_sessions" },
    :path => '/nemid',
    :path_names => {:sign_in => 'login', :sign_out => 'logout'}

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :rest do
    resources :users, :only => [ :show ]
    get 'create_dtu/:id' => 'users#dtu', :as => 'create_dtu'
  end

end

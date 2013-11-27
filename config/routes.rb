Riyosha::Application.routes.draw do
  get "home/index"
  root :to => 'home#index'

  devise_for :users,
    :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks",
      :sessions => "users/sessions",
      :registrations => "users/registrations",
    },
    :path => '/users',
    :path_names => {:sign_in => 'login', :sign_out => 'logout'}
  devise_scope :user do
    get "users/:id/update_address", :to => "users/registrations#update_address",
      :as => "user_update_address"
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

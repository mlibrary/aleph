Riyosha::Application.routes.draw do
  get "home/index"
  root :to => 'home#index'

  devise_for :user,
    :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks",
      :sessions => "users/sessions"
    },
    :path => '/users',
    :path_names => {:sign_in => 'login', :sign_out => 'logout'}

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :rest do
    resources :users, :only => [ :show ]
  end

end

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
    get 'users/profile',            :to => 'users/registrations#show',           :as => 'show_user_registration'
    get 'users/register',           :to => 'users/registrations#dedicated',      :as => 'dedicated_user_registration'
    get 'users/mail',               :to => 'users/confirmations#wait_mail',      :as => 'user_wait_mail'
    get 'users/confirmed',          :to => 'users/confirmations#confirmed',      :as => 'user_confirmed'
  end

  devise_for :ill_users,
    :controllers => {
      :sessions => "ill_users/sessions",
    },
    :path => '/ill_users',
    :path_names => {:sign_in => 'login', :sign_out => 'logout'}
  devise_scope :ill_user do
    get 'ill_users/profile',        :to => 'ill_users/registrations#show',       :as => 'show_ill_user_registration'
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

  namespace :aleph do
    get 'session/new'        => 'sessions#new', :as => 'new_session'
    get 'errors/catch'       => 'errors#catch'
  end
end

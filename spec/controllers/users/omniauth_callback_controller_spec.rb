require 'spec_helper'
 
describe Users::OmniauthCallbacksController  do
  include Devise::TestHelpers

  def self.omniauth_works_for(provider)
    describe provider.to_s do
      before :each do
        request.env["devise.mapping"] = Devise.mappings[:user]
        @mock = OmniAuth.config.mock_auth[provider]
        request.env["omniauth.auth"] = @mock
        @type = UserType.find_by_code('private')
      end

      describe "new user" do
        before :each do
          get provider
          @user = User.first
        end

        it { expect(@user).not_to be_nil }
        it { expect(@user.email).to eq (@mock['info']['email']) }
        it { expect(@user.first_name).to eq (@mock['info']['first_name']) }
        it { expect(@user.last_name).to eq (@mock['info']['last_name']) }
        it { expect(@user.user_type.id).to eq (@type.id) }
      end
    end
  end

  omniauth_works_for(:facebook)
  omniauth_works_for(:linkedin)
  omniauth_works_for(:google_oauth2)

end

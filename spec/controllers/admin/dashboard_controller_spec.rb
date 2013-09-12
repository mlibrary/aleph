require 'spec_helper'
include Devise::TestHelpers

describe Admin::DashboardController do
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
  end

  after(:each) do
    @admin_user.destroy
  end

  describe "Get dashboard" do
    it "renders the dashboard view" do
      get :index
      expect(response.status).to be(200)
      expect(response).to render_template :index
    end
  end
end

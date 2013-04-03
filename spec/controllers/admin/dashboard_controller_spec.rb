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
      response.status.should be(200)
      response.should render_template :index
    end
  end
end

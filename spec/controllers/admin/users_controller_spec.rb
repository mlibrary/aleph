require 'spec_helper'
include Devise::TestHelpers

describe Admin::UsersController do
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
  end

  after(:each) do
    @admin_user.destroy
  end

  describe "GET #index" do
    it "renders the :index view" do
      FactoryGirl.create(:user)
      get :index
      expect(response.status).to be(200)
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "renders the #show view" do
      get :show, id: FactoryGirl.create(:user)
      expect(response.status).to be(200)
      expect(response).to render_template :show
    end
  end

  describe "GET #edit" do
    it "shows the edit template" do
      get :edit, id: FactoryGirl.create(:user)
      expect(response.status).to be(200)
      expect(response).to render_template :edit
    end
  end

end

require 'spec_helper'

describe Rest::UsersController do
  render_views

  describe "GET #show" do
    before :each do
      @user1 = FactoryGirl.create(:user)
      @type = FactoryGirl.create(:user_type, :code => 'dtu_empl')
      @user2 = FactoryGirl.create(:user, :user_type => @type)
    end

    it "renders user" do
      get :show, id: @user1, :format => :json
      response.header['Content-Type'].should include 'application/json'
      response.body.should eq @user1.to_json      
    end

    it "requests dtubase info" do
      get :show, id: @user2, :format => :json
      response.header['Content-Type'].should include 'application/json'
      expanded_user = @user2.as_json
      response.body.should eq expanded_user.to_json
    end
  end
end


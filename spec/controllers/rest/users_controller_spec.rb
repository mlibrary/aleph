require 'spec_helper'

describe Rest::UsersController do
  render_views
  include DtuBaseStub

  before :all do
    dtubase_test_setup
  end

  describe "GET #show" do
    before :each do
      @user1 = FactoryGirl.create(:user)
      @type = FactoryGirl.create(:user_type, :code => 'dtu_empl')
      @user2 = FactoryGirl.create(:user, :user_type => @type)
      @identity = FactoryGirl.create(:identity, :provider => 'dtu',
        :uid => '1', :user => @user2)
    end

    it "renders user" do
      get :show, id: @user1, :format => :json
      response.header['Content-Type'].should include 'application/json'
      expanded_user = @user1.as_json
      expanded_user[:user_type] = @user1.user_type.code
      response.body.should eq expanded_user.to_json      
    end

    it "requests dtubase info" do
      stub_dtubase_cwis_request('dtu_employee_primary', '58')
      get :show, id: @user2, :format => :json
      response.header['Content-Type'].should include 'application/json'
      expanded_user = @user2.as_json
      expanded_user[:user_type] = @type.code
      expanded_user[:dtu] = { :reason => nil, :email => 'employee@test.domain',
        :library_access => '1', :firstname => 'Test', :lastname => 'Employee',
        :initials => 'empl', :matrikel_id => '1', :user_type => 'dtu_empl',
        :org_units => ['58', '55'] }
      response.body.should eq expanded_user.to_json
    end
  end
end


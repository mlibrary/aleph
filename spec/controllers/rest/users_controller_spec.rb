require 'spec_helper'

describe Rest::UsersController do
  render_views
  include DtuBaseStub

  before :all do
    dtubase_test_setup
    @dtu_info = {
      :reason => nil,
      :email => 'employee@test.domain',
      :library_access => '1',
      :firstname => 'Test',
      :lastname => 'Employee',
      :initials => 'empl',
      :matrikel_id => '1',
      :user_type => 'dtu_empl',
      :org_units => ['58', '55']
    }
    @address = {
      "line1" => "Danmarks Tekniske Informationscenter",
      "line2" => "Att: Test Employee",
      "line3" => "Bygning 1, Rum 1",
      "line4" => "Test 2",
      "line5" => nil,
      "line6" => nil,
      "zipcode" => "9999",
      "cityname" => "Test",
      "country" => "dk"
    }
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
      expect(response.header['Content-Type']).to include 'application/json'
      expanded_user = @user1.as_json
      expanded_user[:user_type] = @user1.user_type.code
      expect(response.body).to eq expanded_user.to_json      
    end

    it "requests dtubase info" do
      stub_dtubase_cwis_request('dtu_employee_primary', '58')
      get :show, id: @user2, :format => :json
      expect(response.header['Content-Type']).to include 'application/json'
      expanded_user = @user2.as_json
      expanded_user[:user_type] = @type.code
      expanded_user[:dtu] = @dtu_info
      expanded_user[:address] = @address
      expect(response.body).to eq expanded_user.to_json
    end
  end

  describe "GET #dtu" do
    before :each do
      @type = FactoryGirl.create(:user_type, :code => 'dtu_empl')
    end

    it "creates dtu employee from cwis" do
      stub_dtubase_cwis_request('dtu_employee_primary', '58')
      get :dtu, :id => 1, :format => :json
      expect(User.all.count).to eq 1
      user = User.all.first
      expect(response.header['Content-Type']).to include 'application/json'
      expanded_user = FactoryGirl.build(:user, :user_type => @type,
        :id => user.id, :email => 'employee@test.domain',
        :authenticator => 'dtu', :first_name => 'Test',
        :last_name => 'Employee',
        :created_at => user.created_at, :updated_at => user.updated_at).as_json
      expanded_user[:user_type] = @type.code
      expanded_user[:dtu] = @dtu_info
      expanded_user[:address] = @address
      expect(response.body).to eq expanded_user.to_json
    end

    it "returns existing user from cwis" do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user, :user_type => @type)
      @identity = FactoryGirl.create(:identity, :provider => 'dtu',
        :uid => '1', :user => @user2)
      stub_dtubase_cwis_request('dtu_employee_primary', '58')
      get :dtu, :id => 1, :format => :json
      expect(response.header['Content-Type']).to include 'application/json'
      expanded_user = @user2.as_json
      expanded_user[:user_type] = @type.code
      expanded_user[:dtu] = @dtu_info
      expanded_user[:address] = @address
      expect(response.body).to eq expanded_user.to_json
    end

  end

end


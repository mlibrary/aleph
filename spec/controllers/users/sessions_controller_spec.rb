require 'spec_helper'

describe Users::SessionsController do
  render_views
  include Devise::TestHelpers
  include WebMock::API
  include DtuBaseStub

  describe "new session" do
    before :all do
      DtuBase.config[:url] = 'http://localhost'
      DtuBase.config[:username] = 'x'
      DtuBase.config[:password] = 'p'
      Rails.application.config.dtu_auth_url = 'http://localhost'
    end

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @usertype = FactoryGirl.create(:user_type, :code => 'student')
    end

    after :all do
      WebMock.reset!
    end

    it "shows local_user template" do
      get :new
      response.header['Content-Type'].should include 'text/html'
      # TODO: Should render _local_user partial
    end

    it "shows dtu_user template" do
      get :new, :template => 'dtu_user'
      response.header['Content-Type'].should include 'text/html'
      # TODO: Should render _dtu_user partial
    end

    it "fails validation of ticket" do
       stub_request(:get, "http://localhost/proxyValidate?service="\
         "http://test.host/users/login&ticket=ST-fail-ticket").
         to_return(:status => 404, :body => "", :headers => {})
      assert_raise RuntimeError do
        get :new, :ticket => 'ST-fail-ticket'
      end
    end

    it "validates ticket" do
      stub_valid_ticket
      stub_dtubase_username_request('test', 'stud')
      get :new, :ticket => 'ST-valid-ticket'
      response.header['Content-Type'].should include 'text/html'
    end

#    it "update email on existing user" do
#      ident = FactoryGirl.create(:identity, :provider => 'dtu', :uid => '1')
#      stub_valid_ticket
#      stub_dtubase_username_request('test', 'stud')
#      get :new, :ticket => 'ST-valid-ticket'
#      response.header['Content-Type'].should include 'text/html'
#      user = User.find(ident.user_id)
#      user.email.should eq 'student@test.domain'
#      user.user_type.should eq @user_type
#      user.authenticator.should eq 'dtu'
#    end


    def stub_valid_ticket
      stub_request(:get, "http://localhost/proxyValidate?service="\
        "http://test.host/users/login&ticket=ST-valid-ticket").
        to_return(:status => 200, :body => 
          '<?xml version="1.0" encoding="utf-8"?>'\
          '<cas:serviceResponse xmlns:cas="http://localhost">'\
          '<cas:authenticationSuccess><cas:user>test</cas:user>'\
          '</cas:authenticationSuccess>'\
          "</cas:serviceResponse>", :headers => {})
    end
  end
end

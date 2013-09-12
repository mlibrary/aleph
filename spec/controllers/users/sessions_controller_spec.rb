require 'spec_helper'

describe Users::SessionsController do
  render_views
  include Devise::TestHelpers
  include WebMock::API
  include DtuBaseStub

  describe "new session" do
    before :all do
      dtubase_test_setup
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
      expect(response.header['Content-Type']).to include 'text/html'
      # TODO: Should render _local_user partial
    end

    it "shows dtu_user template" do
      get :new, :template => 'dtu_user'
      expect(response.header['Content-Type']).to include 'text/html'
      # TODO: Should render _dtu_user partial
    end

    it "redirects to dtu" do
      get :new, :only => 'dtu'
      expect(response.status).to be (302)
      expect(response.status).to redirect_to ('http://localhost/login?'+
        'service=http%3A%2F%2Ftest.host%2Fusers%2Flogin')
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
      expect(response.header['Content-Type']).to include 'text/html'
    end

    it "fakes validate ticket" do
      session[:fake_login] = 1
      stub_valid_ticket
      stub_dtubase_cwis_request('test', 'stud')
      get :new, :ticket => 'ST-valid-ticket'
      expect(response.header['Content-Type']).to include 'text/html'
    end

    it "update email on existing user" do
      ident = FactoryGirl.create(:identity, :provider => 'dtu', :uid => '1')
      stub_valid_ticket
      stub_dtubase_username_request('test', 'stud')
      get :new, :ticket => 'ST-valid-ticket'
      expect(response.header['Content-Type']).to include 'text/html'
      user = User.find(ident.user_id)
      expect(user.email).to eq 'student@test.domain'
      expect(user.user_type).to eq @usertype
      expect(user.authenticator).to eq 'dtu'
    end


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

require 'spec_helper'

feature 'When user requests login from a generic service', :js => true do
  let!(:aleph_url) {
    Rails.application.config.aleph[:url] = 'http://localhost/mock_aleph'
  }

  let!(:service_url) {
    'http://localhost/mock_service'
  }

  before(:each) do
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  before(:all) do
    add_mock_service_rails_route
  end

  context 'and user is not logged in' do
    context 'and user is private' do
      context 'and user does not have registered cpr' do
        scenario 'then the user should not be forced to do NemId validation after login' do
          login_with_google
          expect(current_url).to start_with(service_url)
        end
      end
    end

    context 'and the user is library' do
      scenario 'then the user should stay on the registration page' do
        login_as_library
        expect(current_path).to eq(show_ill_user_registration_path)
      end
    end

    scenario 'the validate api should return the non-prefixed user id' do
      login_with_google
      expect(current_url).to start_with(service_url + "?ticket=")

      ticket = Rack::Utils.parse_nested_query(URI(current_url).query)['ticket']
      response = validate_ticket(ticket, service_url)

      expect(response.css('serviceResponse authenticationSuccess user').text).to eq('1')
    end

  end

  def login_as_library
    library_id = 1
    password = 'testtest'
    u = IllUser.create(:library_id => library_id, :email => 'test@expamle.com', :name => 'Test Library',
                       :password => password, :password_confirmation => password,
                       :user_type_id => UserType.find_by_code('library').id, :user_sub_type_id => UserSubType.first.id)

    visit '/ill_users/login?' + {:service => service_url}.to_query
    fill_in 'ill_user_library_id', :with => library_id
    fill_in 'ill_user_password',   :with => password
    click_on 'Log in'
  end

  def login_with_google
    visit '/users/login?' + {:service => service_url}.to_query
    click_link 'Google'
  end

  def validate_ticket(ticket, service)
    visit '/users/serviceValidate?' + {:ticket => ticket, :service => service}.to_query
    return Nokogiri::XML(body).remove_namespaces!
  end

  def add_mock_service_rails_route
    ApplicationController.class_eval do
      define_method(:mock_service, lambda do
        render text: 'mock_service called'
      end)
    end

    test_routes = Proc.new do
      get '/mock_service' => 'application#mock_service'
    end
    Rails.application.routes.eval_block(test_routes)
  end
end

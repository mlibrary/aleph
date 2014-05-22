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

  context 'and user is not logged in' do
    context 'and user is private' do
      context 'and user does not have registered cpr' do
        scenario 'then the user should not be forced to do NemId validation after login' do
          login_with_google
          expect(current_url).to start_with(service_url)
        end
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
  
  def login_with_google
    visit '/users/login?' + {:service => service_url}.to_query
    click_link 'Google'
  end

  def validate_ticket(ticket, service)
    visit '/users/serviceValidate?' + {:ticket => ticket, :service => service}.to_query
    return Nokogiri::XML(body).remove_namespaces!
  end

end

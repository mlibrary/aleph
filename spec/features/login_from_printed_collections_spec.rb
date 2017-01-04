require 'spec_helper'

feature 'When user requests login from printed collections', :js => true do
  let(:aleph_url) { 
    Rails.application.config.aleph[:url] = 'http://localhost/mock_aleph' 
    Rails.application.config.aleph[:url] = 'http://localhost/mock_aleph' 
  }

  before(:each) do
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  before(:all) do
    add_mock_alpeh_rails_route
  end

  context 'and user is not logged in' do
    context 'and user is library' do
      scenario 'then the user should not be forced to do CPR validation after login' do
        login_as_library
        expect(current_url).to start_with(aleph_url + "?ticket=")
      end
    end

    context 'and user is private' do
      context 'and user does not have registered cpr' do
        scenario 'then the user should be forced to do CPR validation after login' do
          login_with_google
          expect(current_path).to eq(show_user_registration_path)

          #validate_nemid
          register_cpr

          expect(current_url).to start_with(aleph_url + "?ticket=")
        end
      end
      
      context 'and user already has registered cpr' do
        scenario 'then the user should not forced to do CPR validation after login' do
          login_with_google
          #validate_nemid
          register_cpr
          logout
          
          login_with_google
          expect(current_url).to start_with(aleph_url + "?ticket=")
        end
      end
    end
    
    scenario 'the validate api should return the prefixed user id' do
      login_with_google
      #validate_nemid
      register_cpr
      expect(current_url).to start_with(aleph_url + "?ticket=")

      ticket = Rack::Utils.parse_nested_query(URI(current_url).query)['ticket']
      response = validate_ticket(ticket)
      expect(response).to eq("yes #{Rails.application.config.aleph[:prefix]}-1X")
    end
  end

  def login_as_library
    library_id = 1
    password = 'testtest'
    u = IllUser.create(:library_id => library_id, :email => 'test@expamle.com', :name => 'Test Library',
                       :password => password, :password_confirmation => password, 
                       :user_type_id => UserType.find_by_code('library').id, :user_sub_type_id => UserSubType.first.id)

    visit '/ill_users/login?' + {:service => aleph_url}.to_query
    fill_in 'ill_user_library_id', :with => library_id
    fill_in 'ill_user_password',   :with => password
    click_on 'Log in'
  end

  def login_with_google
    visit '/users/login?' + {:service => aleph_url}.to_query
    click_link 'Google'
  end

  def validate_nemid
    check('accept_payment_terms')
    check('accept_printed_terms')
    click_on('Register using NemID')
    click_on('Validate NemID')
  end

  def register_cpr
    check 'accept_payment_terms'
    check 'accept_printed_terms'
    fill_in 'cpr1', :with => '010101-1234'
    fill_in 'cpr2', :with => '010101-1234'
    click_on 'Register'
  end

  def validate_ticket(ticket)
    # aleph uses CAS 1.0 protocol
    visit '/users/validate?' + {:ticket => ticket, :service => aleph_url}.to_query
    return page.document.text
  end
  
  def logout
    visit '/users/logout'
  end

  def add_mock_alpeh_rails_route
    ApplicationController.class_eval do
      define_method(:mock_aleph, lambda do
        render text: 'mock_aleph called'
      end)
    end

    test_routes = Proc.new do
      get '/mock_aleph' => 'application#mock_aleph'
    end
    Rails.application.routes.eval_block(test_routes)
  end
end

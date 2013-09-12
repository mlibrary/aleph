require 'spec_helper'

describe SendIt do
  before :all do
    Rails.application.config.action_mailer.delivery_method = :do
    Rails.application.config.sendit_url = 'http://test.host'
  end

  after :all do
    Rails.application.config.action_mailer.delivery_method = :test
  end

  before :each do
    @user = User.new
    @sendit = SendIt.send(:new)
  end

  it "sends confirmation instructions" do
    good_sendit_request('confirmation', 'confirmation_url', 'confirmation')
    @sendit.confirmation_instructions(@user, { 'option1' => 'true' })
  end

  it "sends reset password instructions" do
    good_sendit_request('reset_password', 'edit_password_url',
      'password/edit')
    @sendit.reset_password_instructions(@user, { 'option1' => 'true' })
  end

  it "sends unlock instructions" do
    good_sendit_request('unlock', 'unlock_url', 'unlock')
    @sendit.unlock_instructions(@user, { 'option1' => 'true' })
  end

  it "fails to send" do
    bad_sendit_request('unlock', 'unlock_url', 'unlock')
    assert_raise RuntimeError do
      @sendit.unlock_instructions(@user, { 'option1' => 'true' })
    end
  end

  def good_sendit_request(template, url, link)
    sendit_request(template, url, link, 200)
  end

  def bad_sendit_request(template, url, link)
    sendit_request(template, url, link, 404)
  end

  def sendit_request(template, url, link, code)
    stub_request(:post, "http://test.host/send/riyosha_#{template}").
      with(:body => "{\"from\":\"noreply@dtic.dtu.dk\",\"priority\":\"now\","+
        "\"option1\":\"true\",\"user\":{\"authenticator\":null,"+
        "\"created_at\":null,\"email\":\"\",\"first_name\":null,\"id\":null,"+
        "\"last_name\":null,\"updated_at\":null,\"user_type_id\":null},"+
        "\"to\":\"\","+
        "\"#{url}\":\"http://localhost/users/#{link}\"}",
      :headers => {'Content-Type'=>'application/json'}).
        to_return(:status => code, :body => "", :headers => {})
  end
end

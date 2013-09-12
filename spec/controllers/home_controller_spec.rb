require 'spec_helper'

describe HomeController do
  render_views

  it "renders index page" do
    Rails.application.config.main_service_url = nil
    get :index
    expect(response.status).to be (200)
    expect(response).to render_template :index
  end

  it "redirects index page" do
    Rails.application.config.main_service_url = "http://localhost"
    get :index
    expect(response.status).to be (302)
    expect(response).to redirect_to 'http://localhost'
  end
end

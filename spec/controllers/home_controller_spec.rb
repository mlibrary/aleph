require 'spec_helper'

describe HomeController do
  render_views

  it "redirects index page" do
    get :index
    expect(response.status).to be (302)
    expect(response).to redirect_to edit_user_registration_path
  end
end

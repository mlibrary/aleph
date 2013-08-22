require 'spec_helper'

describe User do
  it "has a valid factory" do
    FactoryGirl.create(:user).should be_valid
  end

  it "fails without email" do
    FactoryGirl.build(:user, email: nil).should_not be_valid
  end

#  it "fails without password" do
#    FactoryGirl.build(:user, password: nil).should_not be_valid
#  end

#  it "fails without password_confirmation" do
#    FactoryGirl.build(:user, password_confirmation: nil).should_not be_valid
#  end

  it "email is unique" do
    user = FactoryGirl.create(:user)
    FactoryGirl.build(:user, email: user.email).should_not be_valid
  end

  it "name is filled for regular user" do
    FactoryGirl.build(:user, :first_name => nil).should_not be_valid
    FactoryGirl.build(:user, :last_name => nil).should_not be_valid
  end

  it "name is not filled for anon user" do
    user_type = FactoryGirl.create(:user_type, code: "anon")
    FactoryGirl.build(:user, :user_type => user_type, :first_name => nil,
      :last_name => nil).should be_valid
  end

  it "create from omniauth" do
    type = FactoryGirl.create(:user_type)
    user = User.create_from_omniauth(OmniAuth.config.mock_auth[:facebook], type.id)
    user.persisted?.should be true
    user.email.should eq 'facebook@test.domain'
    user.confirmed?.should be true
  end

  it "create from dtubasen" do
    type = FactoryGirl.create(:user_type)
    dtu_base = {
      'email' => 'dtu@test.domain',
      'firstname' => 'First',
      'lastname' => 'Last',
    }
    user = User.create_from_dtu(dtu_base, type.id)
    user.persisted?.should be true
    user.email.should eq 'dtu@test.domain'
    user.confirmed?.should be true
  end

end

require 'spec_helper'

describe User do
  it "has a valid factory" do
    FactoryGirl.create(:user).should be_valid
  end

  it "fails without email" do
    FactoryGirl.build(:user, email: nil).should_not be_valid
  end

  it "fails without password" do
    FactoryGirl.build(:user, password: nil).should_not be_valid
  end

  it "fails without password_confirmation" do
    FactoryGirl.build(:user, password_confirmation: nil).should_not be_valid
  end

  it "email is unique" do
    user = FactoryGirl.create(:user)
    FactoryGirl.build(:user, email: user.email).should_not be_valid
  end
end

require 'spec_helper'

describe AdminUser do

  it "has a valid factory" do
    FactoryGirl.create(:admin_user).should be_valid
  end

  it "fails without username" do
    FactoryGirl.build(:admin_user, username: nil).should_not be_valid
  end

  it "username is unique" do
    admin_user = FactoryGirl.create(:admin_user)
    FactoryGirl.build(:admin_user, username: admin_user.username).should_not be_valid
  end

end

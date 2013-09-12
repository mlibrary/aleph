require 'spec_helper'

describe AdminUser do

  it "has a valid factory" do
    expect(FactoryGirl.create(:admin_user)).to be_valid
  end

  it "fails without username" do
    expect(FactoryGirl.build(:admin_user, username: nil)).not_to be_valid
  end

  it "username is unique" do
    admin_user = FactoryGirl.create(:admin_user)
    expect(FactoryGirl.build(:admin_user,
      :username => admin_user.username)).not_to be_valid
  end

end

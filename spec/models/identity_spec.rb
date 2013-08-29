require 'spec_helper'

describe Identity do
  it "has a valid factory" do
    FactoryGirl.create(:identity).should be_valid
  end

  it "fails without user" do
    FactoryGirl.build(:identity, user: nil).should_not be_valid
  end

  it "fails without uid" do
    FactoryGirl.build(:identity, uid: nil).should_not be_valid
  end

  it "fails without provider" do
    FactoryGirl.build(:identity, provider: nil).should_not be_valid
  end

  it "provider, uid is unique" do
    identity = FactoryGirl.create(:identity)
    FactoryGirl.build(:identity, uid: identity.uid, provider: identity.provider).should_not be_valid
    FactoryGirl.build(:identity, uid: "testinguid", provider: identity.provider).should be_valid
    FactoryGirl.build(:identity, uid: identity.uid, provider: "testingprovider").should be_valid
  end

  it "find from omniauth" do
    identity = FactoryGirl.create(:identity)
    auth = OmniAuth::AuthHash.new(
      "provider" => identity.provider,
      "uid" => identity.uid )
    result = Identity.find_with_omniauth(auth)
    result.should eq identity
  end

end

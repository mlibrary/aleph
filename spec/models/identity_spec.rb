require 'spec_helper'

describe Identity do
  it "has a valid factory" do
    expect(FactoryGirl.create(:identity)).to be_valid
  end

  it "fails without user" do
    expect(FactoryGirl.build(:identity, user: nil)).not_to be_valid
  end

  it "fails without uid" do
    expect(FactoryGirl.build(:identity, :uid => nil)).not_to be_valid
  end

  it "fails without provider" do
    expect(FactoryGirl.build(:identity, :provider => nil)).not_to be_valid
  end

  context "provider, uid is unique" do
    before :each do
      @identity = FactoryGirl.create(:identity)
    end

    it do
      expect(FactoryGirl.build(:identity, :uid => @identity.uid, :provider =>
        @identity.provider)).not_to be_valid
    end

    it do
      expect(FactoryGirl.build(:identity, :uid => "testinguid", :provider =>
        @identity.provider)).to be_valid
    end

    it do
      expect(FactoryGirl.build(:identity, :uid => @identity.uid, :provider =>
        "testingprovider")).to be_valid
    end
  end

  it "find from omniauth" do
    identity = FactoryGirl.create(:identity)
    auth = OmniAuth::AuthHash.new(
      "provider" => identity.provider,
      "uid" => identity.uid )
    result = Identity.find_with_omniauth(auth)
    expect(result).to eq identity
  end

end

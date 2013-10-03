require 'spec_helper'

describe UserSubType do
  it "has a valid factory" do
    expect(FactoryGirl.build(:user_sub_type)).to be_valid
  end

  it "fails without code" do
    expect(FactoryGirl.build(:user_sub_type, :code => nil)).not_to be_valid
  end

  it "fails without user_type" do
    expect(FactoryGirl.build(:user_sub_type, :user_type => nil)).not_to be_valid
  end

  describe "aleph_bor_status" do
    it "works with nil" do
      expect(FactoryGirl.build(:user_sub_type,
        :aleph_bor_status => nil)).to be_valid
    end

    it "fails when not numeric" do
      expect(FactoryGirl.build(:user_sub_type,
        :aleph_bor_status => 'ed')).not_to be_valid
    end

    it "works when numeric" do
      expect(FactoryGirl.build(:user_sub_type,
        :aleph_bor_status => 5)).to be_valid
    end
  end

  describe "aleph_bor_type" do
    it "works with nil" do
      expect(FactoryGirl.build(:user_sub_type,
        :aleph_bor_type => nil)).to be_valid
    end

    it "fails when not numeric" do
      expect(FactoryGirl.build(:user_sub_type,
        :aleph_bor_type => 'ed')).not_to be_valid
    end

    it "works when numeric" do
      expect(FactoryGirl.build(:user_sub_type,
        :aleph_bor_type => 5)).to be_valid
    end
  end

  context "user_type, user_sub_type is unique" do
    before :each do
      @user_sub_type = FactoryGirl.create(:user_sub_type)
    end

    it do
      expect(FactoryGirl.build(:user_sub_type, :code => @user_sub_type.code,
        :user_type => @user_sub_type.user_type)).not_to be_valid
    end

    it do
      expect(FactoryGirl.build(:user_sub_type, :code => "testingcode",
        :user_type => @user_sub_type.user_type)).to be_valid
    end

    it do
      user_type = FactoryGirl.create(:user_type)
      expect(FactoryGirl.build(:user_sub_type, :code => @user_sub_type.code,
        :user_type => user_type)).to be_valid
    end
  end
end

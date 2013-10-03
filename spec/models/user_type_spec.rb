require 'spec_helper'

describe UserType do
  it "has a valid factory" do
    expect(FactoryGirl.build(:user_type)).to be_valid
  end

  it "fails without code" do
    expect(FactoryGirl.build(:user_type, :code => nil)).not_to be_valid
  end

  context "aleph_bor_status" do
    it "fails when nil" do
      expect(FactoryGirl.build(:user_type,
        :aleph_bor_status => nil)).not_to be_valid
    end

    it "fails when not numeric" do
      expect(FactoryGirl.build(:user_type,
        :aleph_bor_status => 'ed')).not_to be_valid
    end

    it "work when numeric" do
      expect(FactoryGirl.build(:user_type,
        :aleph_bor_status => 5)).to be_valid
    end
  end

  context "aleph_bor_type" do
    it "fails without aleph_bor_type" do
      expect(FactoryGirl.build(:user_type,
        :aleph_bor_type => nil)).not_to be_valid
    end

    it "fails when not numeric" do
      expect(FactoryGirl.build(:user_type,
        :aleph_bor_type => 'ed')).not_to be_valid
    end

    it "work when numeric" do
      expect(FactoryGirl.build(:user_type,
        :aleph_bor_type => 5)).to be_valid
    end
  end

  it "returns untranslated name" do
    user_type = FactoryGirl.build(:user_type)
    expect(user_type.name).to eq "translation missing: "+
      "en.riyosha.code.user_type."+user_type.code
  end

  it "code is unique" do
    user_type = FactoryGirl.create(:user_type)
    expect(FactoryGirl.build(:user_type,
      :code => user_type.code)).not_to be_valid
  end

end

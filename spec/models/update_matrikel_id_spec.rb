require 'spec_helper'

describe UpdateMatrikelId do
  it "updates the matching identity" do
    user = FactoryGirl.create(:user, :id => 1)
    user.save!
    identity = FactoryGirl.create(:identity, :id => 1, :uid => "101", :provider => "dtu", :user => user)
    identity.save!

    UpdateMatrikelId.new("101", "102").call

    identity_after_update = Identity.where(:id => 1).first
    expect(identity_after_update).not_to be_nil
    expect(identity_after_update.uid).to eq("102")
  end

  it "does not update identites where provider != dtu" do
    user = FactoryGirl.create(:user, :id => 1)
    user.save!
    identity = FactoryGirl.create(:identity, :id => 1, :uid => "101", :provider => "not_dtu", :user => user)
    identity.save!

    UpdateMatrikelId.new("101", "102").call

    identity_after_update = Identity.where(:id => 1).first
    expect(identity_after_update).not_to be_nil
    expect(identity_after_update.uid).to eq("101")
  end

  it "does not throw an exception when no identity is updated" do
    UpdateMatrikelId.new("101", "102").call
  end

  it "throws an exception if the update would have caused multiple identites to have the same uid" do
    user_1 = FactoryGirl.create(:user, :id => 1)
    user_1.save!
    identity_1 = FactoryGirl.create(:identity, :id => 1, :uid => "101", :provider => "dtu", :user => user_1)
    identity_1.save!

    user_2 = FactoryGirl.create(:user, :id => 2)
    user_2.save!
    identity_2 = FactoryGirl.create(:identity, :id => 2, :uid => "102", :provider => "dtu", :user => user_2)
    identity_2.save!

    exception_thrown = false
    begin
      UpdateMatrikelId.new("101", "102").call
    rescue => e
      exception_thrown = true
    end

    expect(exception_thrown).to eq(true)
  end
end

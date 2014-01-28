require 'spec_helper'

describe User do
  it "has a valid factory" do
    expect(FactoryGirl.create(:user)).to be_valid
  end

  it "fails without email" do
    expect(FactoryGirl.build(:user, email: nil)).not_to be_valid
  end

#  it "fails without password" do
#    FactoryGirl.build(:user, password: nil).should_not be_valid
#  end

#  it "fails without password_confirmation" do
#    FactoryGirl.build(:user, password_confirmation: nil).should_not be_valid
#  end

  it "email is unique" do
    user = FactoryGirl.create(:user)
    expect(FactoryGirl.build(:user, email: user.email)).not_to be_valid
  end

  context "Regular users" do
    it "firstname is filled" do
      expect(FactoryGirl.build(:user, :first_name => nil)).not_to be_valid
    end

    it "lastname is filled" do
      expect(FactoryGirl.build(:user, :last_name => nil)).not_to be_valid
    end

    it "fails with @dtu.dk mail address" do
      expect(FactoryGirl.build(:user, :email => 'no@dtu.dk')).not_to be_valid
    end

    it "fails with .dtu.dk mail address" do
      expect(FactoryGirl.build(:user, :email => 'no@x.dtu.dk')).not_to be_valid
    end
  end

  it "name is not filled for anon user" do
    user_type = FactoryGirl.create(:user_type, code: "anon")
    expect(FactoryGirl.build(:user, :user_type => user_type,
      :first_name => nil, :last_name => nil)).to be_valid
  end

  it "Lastname is not filled for library user" do
    user_type = FactoryGirl.create(:user_type, code: "library")
    expect(FactoryGirl.build(:user, :user_type => user_type,
      :first_name => "Library", :last_name => nil)).to be_valid
  end

  describe "omniauth" do
    before :each do
      @type = FactoryGirl.create(:user_type, code: 'testing')
      @mock1 = OmniAuth.config.mock_auth[:facebook]
      @user1 = User.login_from_omniauth(@mock1)
    end

    context "create" do
      it { expect(@user1.persisted?).to be true }
      it { expect(@user1.email).to eq(@mock1['info']['email']) }
      it { expect(@user1.confirmed?).to be true }
    end

    context "update" do
      before :each do
        @mock2 = OmniAuth.config.mock_auth[:facebook_update]
        @user2 = User.login_from_omniauth(@mock2)
      end

      it { expect(@user2.id).to eq(@user1.id) }
      it { expect(@user2.email).to eq(@mock2['info']['email']) }
      it { expect(@user2.first_name).to eq(@mock2['info']['first_name']) }
      it { expect(@user2.last_name).to eq(@mock2['info']['last_name']) }
    end
  end

end

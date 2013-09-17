require 'spec_helper'

describe Address do
  it "has a valid factory" do
    expect(FactoryGirl.create(:address)).to be_valid
  end

  it "fails without line1" do
    expect(FactoryGirl.build(:address, :line1 => nil)).not_to be_valid
  end

  it "fails without line2" do
    expect(FactoryGirl.build(:address, :line2 => nil)).not_to be_valid
  end

  it "fails without zipcode" do
    expect(FactoryGirl.build(:address, :zipcode => nil)).not_to be_valid
  end

  it "fails without type" do
    expect(FactoryGirl.build(:address, :cityname => nil)).not_to be_valid
  end

  it "name filled" do
    address = FactoryGirl.build(:address)
    expect(address.name).to eq "#{address.line1}, #{address.line2}, "+
      "#{address.zipcode} #{address.cityname}"
  end

end

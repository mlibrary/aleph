require 'spec_helper'

describe SynchronizeWithDtubase do
  include WebMock::API
  include DtuBaseStub

  before :all do
    DtuBase.config[:url] = 'http://localhost'
    DtuBase.config[:username] = 'x'
    DtuBase.config[:password] = 'p'
    @dtubase_stub_url = "http://localhost/?XPathExpression=/removed_account&dbversion=dtubasen&password=p&username=x"
  end

  after :all do
    WebMock.reset!
  end

  it "updates Identity uid based on accounts removed in dtubase" do
    user = FactoryGirl.create(:user, :id => 1)
    user.save!
    identity = FactoryGirl.create(:identity, :id => 1, :uid => "182281", :provider => "dtu", :user => user)
    identity.save!

    another_user = FactoryGirl.create(:user, :id => 2)
    another_user.save!
    another_identity = FactoryGirl.create(:identity, :id => 2, :uid => "113623", :provider => "dtu", :user => another_user)
    another_identity.save!

    body = '<?xml version="1.0" encoding="utf-8"?>'\
           '<root>'\
           '<removed_account removed_matrikel_id="329580" new_matrikel_id="94022" />'\
           '<removed_account removed_matrikel_id="113623" new_matrikel_id="17085" date_removed="2016-10-13T12:32:48.470" />'\
           '<removed_account removed_matrikel_id="182281" new_matrikel_id="44588" date_removed="2011-08-11T15:40:12.200" />'\
           '</root>'
    stub_request(:get, @dtubase_stub_url).
     to_return(:status => 200, :body => body, :headers => {"Content-Type" => "text/xml; charset=utf-8"})

    SynchronizeWithDtubase.new.call

    identity_after_update = Identity.where(:id => 1).first
    expect(identity_after_update).not_to be_nil
    expect(identity_after_update.uid).to eq("44588")

    another_identity_after_update = Identity.where(:id => 2).first
    expect(another_identity_after_update).not_to be_nil
    expect(another_identity_after_update.uid).to eq("17085")
  end

  it "handles events from Dtubase chronologically" do
    user = FactoryGirl.create(:user, :id => 1)
    user.save!
    identity = FactoryGirl.create(:identity, :id => 1, :uid => "182281", :provider => "dtu", :user => user)
    identity.save!

    body = '<?xml version="1.0" encoding="utf-8"?>'\
           '<root>'\
           '<removed_account removed_matrikel_id="44588" new_matrikel_id="17085" date_removed="2016-10-13T12:32:48.470" />'\
           '<removed_account removed_matrikel_id="182281" new_matrikel_id="44588" date_removed="2011-08-11T15:40:12.200" />'\
           '</root>'
    stub_request(:get, @dtubase_stub_url).
     to_return(:status => 200, :body => body, :headers => {"Content-Type" => "text/xml; charset=utf-8"})

    SynchronizeWithDtubase.new.call

    identity_after_update = Identity.where(:id => 1).first
    expect(identity_after_update).not_to be_nil
    expect(identity_after_update.uid).to eq("17085")
  end

  it "is idempotent" do
    user = FactoryGirl.create(:user, :id => 1)
    user.save!
    identity = FactoryGirl.create(:identity, :id => 1, :uid => "182281", :provider => "dtu", :user => user)
    identity.save!

    another_user = FactoryGirl.create(:user, :id => 2)
    another_user.save!
    another_identity = FactoryGirl.create(:identity, :id => 2, :uid => "113623", :provider => "dtu", :user => another_user)
    another_identity.save!

    body = '<?xml version="1.0" encoding="utf-8"?>'\
           '<root>'\
           '<removed_account removed_matrikel_id="329580" new_matrikel_id="94022" />'\
           '<removed_account removed_matrikel_id="113623" new_matrikel_id="17085" date_removed="2016-10-13T12:32:48.470" />'\
           '<removed_account removed_matrikel_id="182281" new_matrikel_id="44588" date_removed="2011-08-11T15:40:12.200" />'\
           '</root>'
    stub_request(:get, @dtubase_stub_url).
     to_return(:status => 200, :body => body, :headers => {"Content-Type" => "text/xml; charset=utf-8"})

    synchronize_with_dtubase = SynchronizeWithDtubase.new
    synchronize_with_dtubase.should_receive(:update_account).with("329580", "94022")
    synchronize_with_dtubase.should_receive(:update_account).with("113623", "17085")
    synchronize_with_dtubase.should_receive(:update_account).with("182281", "44588")
    synchronize_with_dtubase.call

    body = '<?xml version="1.0" encoding="utf-8"?>'\
           '<root>'\
           '<removed_account removed_matrikel_id="329580" new_matrikel_id="94022" />'\
           '<removed_account removed_matrikel_id="113623" new_matrikel_id="17085" date_removed="2016-10-13T12:32:48.470" />'\
           '<removed_account removed_matrikel_id="182281" new_matrikel_id="44588" date_removed="2011-08-11T15:40:12.200" />'\
           '<removed_account removed_matrikel_id="1" new_matrikel_id="2" date_removed="2016-12-11T15:40:12.200" />'\
           '</root>'
    stub_request(:get, @dtubase_stub_url).
     to_return(:status => 200, :body => body, :headers => {"Content-Type" => "text/xml; charset=utf-8"})

    another_synchronize_with_dtubase = SynchronizeWithDtubase.new
    another_synchronize_with_dtubase.should_not_receive(:update_account).with("329580", "94022")
    another_synchronize_with_dtubase.should_not_receive(:update_account).with("113623", "17085")
    another_synchronize_with_dtubase.should_not_receive(:update_account).with("182281", "44588")
    another_synchronize_with_dtubase.should_receive(:update_account).with("1", "2")
    another_synchronize_with_dtubase.call
  end
end

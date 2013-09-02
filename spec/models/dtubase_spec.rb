require 'spec_helper'

describe DtuBase do
  include WebMock::API
  include DtuBaseStub

  before :all do
    DtuBase.config[:url] = 'http://localhost'
    DtuBase.config[:username] = 'x'
    DtuBase.config[:password] = 'p'
  end

  after :all do
    WebMock.reset!
  end

  describe "lookup" do
    it "lookups student primary" do
      lookup("student_primary", 'stud')
    end

    it "lookups student active" do
      lookup("student_active", 'stud')
    end

    it "lookups dtu employee primary" do
      lookup("dtu_employee_primary", '58')
    end

    it "lookups dtu employee active" do
      lookup("dtu_employee_active", '58')
    end

    it "lookups student phd primary" do
      lookup("student_phd_primary", '58')
    end

    it "lookups student phd active" do
      lookup("student_phd_active", 'stud')
    end

    it "lookups guest primary" do
      lookup("guest_primary", '10')
    end

    it "lookups guest active" do
      lookup("guest_active", '10')
    end

    def lookup(name, org_unit)
      stub_dtubase_cwis_request(name, org_unit)

      result = File.read("spec/fixtures/dtubase/#{name}.json")
      result = result.gsub(/\n */, "")

      info = DtuBase.lookup(:cwis => 1)
      info.to_json.should eq result
    end

  end

  describe "lookup failure" do
    it "return nil" do
      stub_request(:get, "http://localhost/?XPathExpression=/account"\
        "[@matrikel_id='1']&dbversion=dtubasen&password=p&username=x").
        to_return(:status => 404, :body => "", :headers => {})
      info = DtuBase.lookup(:cwis => 1)
      info['reason'].should eq "lookup_failed"
    end
  end

end
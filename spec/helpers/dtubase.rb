module DtuBaseStub

  def dtubase_test_setup
    DtuBase.config[:url] = 'http://localhost'
    DtuBase.config[:username] = 'x'
    DtuBase.config[:password] = 'p'
  end

  def stub_dtubase_cwis_request(name, org_unit)
    stub_dtubase_orgunit(org_unit)

    body = File.read("spec/fixtures/dtubase/#{name}.xml")
    stub_request(:get, "http://localhost/?XPathExpression=/account"\
      "[@matrikel_id='1']&dbversion=dtubasen&password=p&username=x").
      to_return(:status => 200, :body => body, :headers => {})
  end

  def stub_dtubase_username_request(name, org_unit)
    stub_dtubase_orgunit(org_unit)

    body = File.read("spec/fixtures/dtubase/#{name}.xml")
    stub_request(:get, "http://localhost/?XPathExpression=/account"\
      "[@username='#{name}']&dbversion=dtubasen&password=p&username=x").
      to_return(:status => 200, :body => body, :headers => {})
  end

  def stub_dtubase_orgunit(org_unit)
    body = File.read("spec/fixtures/dtubase/org_#{org_unit}.xml")
    stub_request(:get, "http://localhost/?XPathExpression=/orgunit"\
      "[@orgunit_id='#{org_unit}']&dbversion=dtubasen&password=p&username=x").
     to_return(:status => 200, :body => body, :headers => {})
  end

end


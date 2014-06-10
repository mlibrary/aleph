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

  describe "parse" do
    it "parses a student account" do      
      stub_dtubase_orgunit('stud')
      entry = Nokogiri.XML(<<EOF, nil, 'UTF-8')
<?xml version="1.0" encoding="utf-8"?>
<root>
  <account matrikel_id="63905" cprnr="100390-1315" last_updated="2013-11-28T05:13:00" last_updated_all="2014-06-03T09:09:00" auth_gateway="unix" fk_createdby_matrikel_id="1" username="s103509" sysadm="0" firstname="Jakob" lastname="Malmskov" title="" company_address="" company_address_is_primary="0" company_address_is_hidden="1" temporary_address="" temporary_address_is_primary="0" temporary_address_is_hidden="1" private_homepage_url="" official_email_address="s103509@student.dtu.dk" official_picture_url="https://www.dtubasen.dtu.dk/showimage.aspx?id=63905" official_picture_hide_in_cn="1" sms_provider="" sms_phone="25711171" library_pincode="" library_username="" primary_profile_id="82371" preferred_language="dk" hide_private_address="0" note="" has_active_profile="1" external_Phonebook="0" external_Portalen="0" external_Biblioteket="0" external_Software="1" nextOfKinName="" nextOfKinRelation="" nextOfKinTelephone="">
    <private_address address_id="138480" hide_address="1" is_primary_address="1" is_secret_address="0" street="Nybrovej 304,1,-M-64" building="" room="" zipcode="2800" city="Kgs. Lyngby" country="DK" phone1="" phone2="" phone3="" mobile_phone="" fax="" picture_url="" homepage_url="" email_address="" institution_name="" institution_number="" title="" location_map_name="" location_map_coordinates="" />
    <profile_student fk_profile_id="82371" phd_scanpas="" fk_createdby_matrikel_id="1" last_updated="2014-06-03T09:09:00" fk_matrikel_id="63905" fk_orgunit_id="stud" active="1" exchange="0" phd="0" open_university="0" ordinary="1" admission="0" stads_userid="103509" stads_studentcode="s103509" study_line="" study_frame="DARK02" study_frame2="ARKTISK" point="220" note="" mail_servername="cnserv.student.dtu.dk" mail_servertype="IMAP4" ftp_servername="ftp.student.dtu.dk" ftp_serverport="21" ftp_homedir="/" ftp_username="s103509" Adresseland="" Nationalitet="DK" ApplicationNo="" optagelsesaar="2010" uddannelse_dk="diploming." uddannelse_uk="Master in Engineering" retning_dk="Arktisk tek." retning_uk="">
      <date_created>2010-08-05T04:28:00</date_created>
      <ramme_start_dato>2010-09-01T00:00:00</ramme_start_dato>
      <address address_id="138481" hide_address="1" is_primary_address="0" is_secret_address="0" street="Nybrovej 304,1,-M-64" building="" room="" zipcode="2800" city="Kgs. Lyngby" country="DK" phone1="" phone2="" phone3="" mobile_phone="" fax="" picture_url="" homepage_url="" email_address="s103509@student.dtu.dk" institution_name="" institution_number="" title="studerende" location_map_name="" location_map_coordinates="" />
    </profile_student>
  </account>
</root>
EOF
      d = DtuBase.new
      d.parse_account(entry.xpath('//account'))
      puts [d.to_hash, d.address].inspect
    end
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

    it "lookups dtu employee third level" do
      stub_dtubase_orgunit('58')
      lookup("dtu_employee_third_level", '5801')
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
      stub_dtubase_orgunit(org_unit)
      stub_dtubase_cwis_request(name)

      result = File.read("spec/fixtures/dtubase/#{name}.json")
      result = result.gsub(/\n */, "")

      address = File.read("spec/fixtures/dtubase/#{name}_address.json")
      address = address.gsub(/\n */, "")

      info, adr = DtuBase.lookup(:cwis => 1)
      expect(info.to_json).to eq result
      expect(adr.to_hash.to_json).to eq address
    end

  end

  describe "lookup failure" do
    it "return nil" do
      stub_request(:get, "http://localhost/?XPathExpression=/account"\
        "[@matrikel_id='1']&dbversion=dtubasen&password=p&username=x").
        to_return(:status => 404, :body => "", :headers => {})
      info, adr = DtuBase.lookup(:cwis => 1)
      expect(info['reason']).to eq "lookup_failed"
    end
  end

end

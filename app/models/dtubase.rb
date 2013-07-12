require 'httparty'
require 'nokogiri'

class DtuBase
  attr_reader :reason, :email, :firstname, :lastname, :initials,
    :matrikel_id, :user_type, :library_access, :org_units

  def self.lookup(attrs)
    dtubase = self.new
    dtubase.lookup_single(attrs)
    dtubase.to_hash
  end

  def lookup_single(attrs)
    identifier = attrs[:cwis] || attrs[:username]
    attr = attrs[:cwis] ? "matrikel_id" : "username"
    response = request('account', attr, identifier)
    unless response.success?
      @reason = 'lookup_failed'
      return
    end

    if Rails.env.development?
      File.open("spec/fixtures/dtubase/person_#{identifier}.local.xml", 'wb') do |f|
        f.write(response.body)
      end
    end
    entry = Nokogiri.XML(response.body, nil, 'UTF-8')
    parse_account(entry.xpath('//account'))
  end

  def parse_account(account)
    # Get the basic information even if we fail later
    @firstname = account.xpath('@firstname').text
    @lastname = account.xpath('@lastname').text
    @email = account.xpath('@official_email_address').text
    @initials = account.xpath('@dtu_initials').text
    @matrikel_id = account.xpath('@matrikel_id').text
    @library_access = account.xpath('@external_Biblioteket').text
    @reason = nil
    @org_units = Array.new
    logger.info "Matrikel id #{matrikel_id}"

    profile = dtu_select_profile(account)
    if profile.nil?
      @reason = 'dtu_no_primary_profile'
      logger.warn "Doing fallback because of missing (active) primary "\
        "profile for #{@matrikel_id}"
      profile = dtu_select_active_profile(account)
      return nil if profile.nil?
    end
    logger.info "User type #{@user_type}"

    # Get organization unit
    org_unit_id = profile.xpath('@fk_orgunit_id').text
    org_unit = get_org_unit(org_unit_id)

    # Org unit must be in the correct groping
    flag = org_unit.xpath('@fk_parentunit_id').text
    if flag != 'instgrp' && flag != 'dtu'
      @reason = 'not_dtu_org'
      #@user_type = 'private'
    end

    # Find organizations unit attached to this user
    # stud is skipped if phd is true.
    list = account.xpath("//*[@active = '1']")
    list.each do |node|
      if "#{node.attribute("phd")}" != '1' || list.count == 1
        id = node.xpath("@fk_orgunit_id").text
        @org_units << id unless @org_units.include?(id)
      end
    end
    logger.info "Lookup complete"

  end

#  def success
#    @reason.nil?
#  end

  def to_hash
    values = Hash.new
    %w(reason email library_access firstname lastname initials matrikel_id
       user_type org_units).each do |k|
      values[k] = send(k)
    end
    values
  end

  def self.config
    Rails.application.config.dtubase
  end

  private

  def dtu_select_profile(account)
    @user_type = nil
    primary_id = account.xpath("@primary_profile_id").text
    logger.info "Primary id #{primary_id}"
    profile = account.xpath(
      "profile_employee[@fk_profile_id = #{primary_id} and @active = '1']")
    if !profile.empty?
      @user_type = "dtu_empl"
    else
      profile = account.xpath(
        "profile_student[@fk_profile_id = #{primary_id} and @active = '1']")
      if !profile.empty?
        @user_type = "student"
      else
        profile = account.xpath(
          "profile_guest[@fk_profile_id = #{primary_id} and @active = '1']")
        @user_type = "dtu_empl"
      end
    end

    return nil if profile.empty?
    profile.first
  end

  def dtu_select_active_profile(account)
    profile = account.xpath("profile_student[@active = '1']")
    if !profile.empty?
      phd = profile.xpath('@phd').text
      logger.info "PHD: #{phd} #{phd == '0'}"
      if phd == '0'
        @user_type = 'student'
        return profile.first
      end
    end

    profile = account.xpath("profile_employee[@active = '1']")
    if !profile.empty?
      @user_type = 'dtu_empl'
      return profile.first 
    end

    profile = account.xpath("profile_guest[@active = '1']")
    if !profile.empty?
      @user_type = 'dtu_empl'
      return profile.first
    end

    # This catches a case when student is marked phd, but no employee
    # entry have been created.
    profile = account.xpath("profile_student[@active = '1']")
    if !profile.empty?
      @reason = "dtu_catch_student_active"
      @user_type = 'student'
      return profile.first 
    end
    return nil
  end

  def get_org_unit (id)
    response = request('orgunit', 'orgunit_id', id)
    return nil if response.nil?
    entry = Nokogiri.XML(response.body, nil, 'UTF-8')
    if Rails.env.development?
      File.open("spec/fixtures/dtubase/org_#{id}.local.xml", 'wb') do |f|
        f.write(response.body)
      end
    end
    entry.xpath('//orgunit')
  end

  def request(type, attr, identifier)
    url = "#{config[:url]}?" +
      URI.encode_www_form(
        :XPathExpression => "/#{type}[@#{attr}=\'%s\']" % identifier,
        :username => config[:username],
        :password => config[:password],
        :dbversion => 'dtubasen'
      )
    response = HTTParty.get(url)
    unless response.success?
      logger.warn "Could not get #{type} with #{attr} containing "\
        "#{identifier} from DTUbasen with request #{url}. Message: "\
        "#{response.message}."
    end
    response
  end

  def logger
    Rails.logger
  end

  def config
    Rails.application.config.dtubase
  end

end

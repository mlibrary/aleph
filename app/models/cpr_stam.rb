require 'httparty'
require 'nokogiri'

class CprStam
  def self.lookup(cpr)
    cprstam = self.new
    cprstam.lookup_cpr(cpr)
    cprstam.address
  end

  def lookup_cpr(cpr)
    response = HTTParty.post config[:url], {
      :body => URI.encode_www_form(
        :cprinfo => cpr,
        :userName => config[:username],
        :Pword => config[:password],
        :Service => 'STAM',
        :valid_status => '01,03,05,07,20,30,50,60,70,80,90'
      )}
    if response.code != 200
      raise ArgumentError
    end
    parse response.body
  end

  def parse(body)
    # The response is xml packed in xml
    entry = Nokogiri.XML(body, nil, 'UTF-8')
    # The inner xml has been converted but header hasn't been fixed
    # Fix header and parse xml again
    entry = Nokogiri.XML(entry.text.gsub("ISO-8859-1", "UTF-8"),
      nil, 'UTF-8')
    # We work in simple mode without namespaces
    entry.remove_namespaces!
    @user = Hash.new
    entry.xpath("//Field").each do |field|
      value = field.attr("v")
      unless value.blank?
        case field.attr("r")
        when "PNR"
          @user['cpr'] = value
        when "ADRNVN"
          names = value.split(",")
          @user['lastname'] = names[0]
          @user['firstname'] = names[1]
        when 'CONVN'
          @user['conavn'] = value
        when 'STADR'
          @user['address1'] = value
        when 'BYNVN'
          @user['address2'] = value
#        when 'LOKALITET'
#          @user['address3'] = value
        when 'POSTNR'
          @user['zipcode'] = value
          @user['cityname'] = field.attr("t")
          @user['country'] = 'DK'
        else
          logger.debug "CPR: #{field.attr("r")} #{value} #{field.attr("t")}"
        end
      end
    end
    logger.info "User: #{@user.inspect}"
  end

  def address
    address = Address.new
    address << "#{@user['firstname']} #{@user['lastname']}"
    address << @user['coadr'] if @user['conavn']
    address << @user['address1'] if @user['address1']
    address << @user['address2'] if @user['address2']
    address.zipcode = @user['zipcode']
    address.cityname = @user['cityname']
    address.country = @user['country']
    address
  end

  def config
    Rails.application.config.cpr
  end

  def logger
    Rails.logger
  end
end


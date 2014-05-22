require 'httparty'
require 'nokogiri'

module Aleph
  class Connection < Base
    include Singleton
    include HTTParty

    # Variables
    #attr_reader :connection
    #
    #   @@connection   HTTParty object for making requests.

    def x_request(func, params)
      url = "#{config.aleph_x_url}/X?op=#{func}"
      # params as key value with encoding
      params.each do |k, v|
        url += "&#{k}=#{URI.encode_www_form_component(v)}"
      end

      if config.test_mode
        logger.info "X Request (test mode) #{url}"
        return self
      end

      logger.info "X Request #{url}"
      response = HTTParty.get(url)
      unless response.success?
        report "Aleph X request failed: #{func} with #{params.inspect} "+
          response.body
        @error = "X request failed"
      end
      @document = Nokogiri.XML(response.body, nil, 'UTF-8')
      logger.info "Response: #{@document}"
      @error = @document.xpath('//error').text
      self
    end


    def success
      if @error.empty?
        @document
      else
        report "Aleph request failed " + @error
        @error = nil
      end
    end

    def success?
      @error.nil?
    end

    def document
      @error = nil
      @document
    end

    def report(text)
      logger.error text
      raise Aleph::Error
    end
  end
end

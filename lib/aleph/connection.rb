# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'singleton'

module Aleph
  class Connection < Base
    include Singleton
    include HTTParty

    # Variables
    # attr_reader :connection
    #
    #   @@connection   HTTParty object for making requests.

    def x_request(func, params)
      url = "#{config.aleph_x_url}/X?op=#{func}"
      # params as key value with encoding
      params.each do |k, v|
        url += "&#{k}=#{URI.encode_www_form_component(v)}"
      end

      return self if config.test_mode

      response = HTTParty.get(url)
      unless response.success?
        report "Aleph X request failed: #{func} with #{params.inspect} " +
               response.body
        @error = 'X request failed'
      end
      @document = Nokogiri.XML(response.body, nil, 'UTF-8')
      @error    = parse_x_response_errors(@document)
      self
    end

    def success
      if @error.empty?
        @document
      else
        report 'Aleph request failed ' + @error
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

    def report(_text)
      raise Aleph::Error
    end

    def parse_x_response_errors(document)
      document.xpath('//error').map(&:text).reject { |e| e.starts_with? 'Succeeded' }.join(' ')
    end
  end
end

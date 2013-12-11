require 'httparty'

class SenditDelivery
  def initialize(values)
    @settings = values.dup
  end

  attr_accessor :settings

  def deliver!(mail)
    begin
      # Craft url with template name
      url = "#{config.sendit_url}/send/#{mail.subject}"
      response = HTTParty.post url, {
        :body => mail.body.to_s,
        :headers => { 'Content-Type' => 'application/json' }
      }
      unless response.code == 200
        logger.error "SendIt responded with HTTP #{response.code}"
        raise "Error communicating with SendIt"
      end
    rescue StandardError => e
      logger.error "Error sending mail: url = #{url} "+
        "- body #{mail.body}"
      logger.error "Exception #{e.message}"
      raise e
    end
  end

  def config
    Rails.application.config
  end

  def logger
    Rails.logger
  end
end

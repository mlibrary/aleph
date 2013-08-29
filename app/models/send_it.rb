require 'httparty'

class SendIt < Devise::Mailer
  include Rails.application.routes.url_helpers
  include Rails.application.routes.mounted_helpers
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, params={})
    params['user'] = record.as_json
    params['to'] = record.email
    params['confirmation_url'] = confirmation_url(record,
      :confirmation_token => record.confirmation_token)
    send_mail 'riyosha_confirmation', params
  end

  def reset_password_instructions(record, params={})
    params['user'] = record.as_json
    params['to'] = record.email
    params['edit_password_url'] = edit_password_url(record,
      :reset_password_token => record.reset_password_token)
    send_mail 'riyosha_reset_password', params
  end

  def unlock_instructions(record, params={})
    params['user'] = record.as_json
    params['to'] = record.email
    params['unlock_url'] = unlock_url(record,
      :unlock_token => record.unlock_token)
    send_mail 'riyosha_unlock', params
  end

  private

  def send_mail template, params = {}
    begin
      url = "#{config.sendit_url}/send/#{template}"

      default_params = {
        :from => 'noreply@dtic.dtu.dk',
        :priority => 'now'
      }
      logger.info "Sending mail request to SendIt: URL = #{url}, template = #{template}, params = #{default_params.deep_merge(params).to_json}"

      unless config.action_mailer.delivery_method == :test
        response = HTTParty.post url, {
          :body => default_params.deep_merge(params).to_json,
          :headers => { 'Content-Type' => 'application/json' }
        } 

        unless response.code == 200
          logger.error "SendIt responded with HTTP #{response.code}"
          raise "Error communicating with SendIt"
        end
      end
    rescue
      logger.error "Error sending mail: template = #{template}\n#{params}"
      raise
    end
  end

  def config
    Rails.application.config
  end

  def logger
    Rails.logger
  end

end

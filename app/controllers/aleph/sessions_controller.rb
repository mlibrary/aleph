class Aleph::SessionsController < ApplicationController
  
  def new
    aleph_url = Rails.application.config.aleph[:url]
    new_aleph_session_url = "#{aleph_url}/F?func=file&file_name=find-b&local_base=dtv01_dtv&con_lng=ENG"
    
    r = HTTParty.get(new_aleph_session_url)
    p = Nokogiri::HTML(r)
    
    new_session = p.xpath("//input[@name='session']/@value").text
    new_session_url = "#{new_session}?" + params.to_query
    logger.info "Redirecting to #{new_session_url}"
 
    redirect_to "#{new_session_url}"
  end
  
end

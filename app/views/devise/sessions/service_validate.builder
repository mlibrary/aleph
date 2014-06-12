# encoding: UTF-8
xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
if @response.status == 200
  xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
    xml.tag!("cas:authenticationSuccess") do
      if aleph_url? @response.service_ticket.service
        xml.tag!("cas:user", Aleph.config.bor_prefix + '-' + @response.service_ticket.ticket_granting_ticket.username.to_s)
      else
        xml.tag!("cas:user", @response.service_ticket.ticket_granting_ticket.username.to_s)
      end
      if @response.service_ticket.ticket_granting_ticket.extra_attributes
        xml.tag!("cas:attributes") do
          @response.service_ticket.ticket_granting_ticket.extra_attributes.each do |key, value|
            namespace_aware_key = key[0..3]=='cas:' ? key : 'cas:' + key
            serialize_extra_attribute(xml, namespace_aware_key, value)
          end
        end
      end
    end
  end
else
  xml.tag!("cas:serviceResponse", 'xmlns:cas' => "http://www.yale.edu/tp/cas") do
    xml.tag!("cas:authenticationFailure", {:code => @response.status},
      I18n.t(@response.error, :scope => 'devise.sessions.cas_server'))
  end
end

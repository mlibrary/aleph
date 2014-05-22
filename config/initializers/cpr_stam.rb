if Rails.application.config.cpr[:stub]
  CprStam.add_mock('123456780123',
    Address.new(:line1 => 'Firstname Lastname', :line2 => 'Streetname 1', :zipcode => '0000', :cityname => 'City', :country => 'DK')
  )
end

if Rails.application.config.omniauth[:stub] 
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      'provider' => 'facebook',
      'uid' => '123545',
      'info' => {
        'email' => 'facebook@test.domain',
        'first_name' => 'Test',
        'last_name' => 'User',
        'user_type' => 'private',
      }
    })
  OmniAuth.config.mock_auth[:facebook_update] = OmniAuth::AuthHash.new({
      'provider' => 'facebook',
      'uid' => '123545',
      'info' => {
        'email' => 'facebook@test.domain',
        'first_name' => 'Test',
        'last_name' => 'User',
        'user_type' => 'private',
      }
    })
  OmniAuth.config.mock_auth[:linkedin] = OmniAuth::AuthHash.new({
      'provider' => 'linkedin',
      'uid' => '123556',
      'info' => {
        'email' => 'linkedin@test.domain',
        'first_name' => 'Test',
        'last_name' => 'User',
        'user_type' => 'private',
      }
    })
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      'provider' => 'google_oauth2',
      'uid' => '123567',
      'info' => {
        'email' => 'google@test.domain',
        'first_name' => 'Test',
        'last_name' => 'User',
        'user_type' => 'private',
      }
    })
end

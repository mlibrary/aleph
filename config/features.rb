
FeatureFlipper.features do
  
  in_state :development do
  end

  in_state :unstable do
  end

  in_state :staging do
  end

  in_state :live do    
  end

end

FeatureFlipper::Config.states = {
  :development => ['development', 'test'].include?(Rails.env),
  :unstable    => ['development', 'test', 'unstable'].include?(Rails.env),
  :staging     => ['development', 'test', 'unstable', 'staging'].include?(Rails.env),
  :live        => true
}

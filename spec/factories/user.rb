FactoryGirl.define do
  factory :user do |f|
    f.sequence(:email) { |n| "email#{n}@local.domain" }
    f.password "Encoded password"
    f.password_confirmation "Encoded password"
    f.association :user_type
  end
end

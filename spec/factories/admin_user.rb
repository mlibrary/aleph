FactoryGirl.define do
  factory :admin_user do |f|
    f.sequence(:username) { |n| "admin#{n}" }
  end
end

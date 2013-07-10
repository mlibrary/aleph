FactoryGirl.define do
  factory :identity do |f|
    f.sequence(:uid) { |n| "uid#{n}" }
    f.sequence(:provider) { |n| "provider#{n}" }
    f.association :user
  end
end

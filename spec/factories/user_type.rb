FactoryGirl.define do
  factory :user_type do |f|
    f.sequence(:code) { |n| "usertype#{n}" }
    f.sequence(:aleph_bor_status) { |n| n }
    f.sequence(:aleph_bor_type) { |n| n }
  end
end

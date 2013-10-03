FactoryGirl.define do
  factory :user_sub_type do |f|
    f.sequence(:code) { |n| "usersub#{n}" }
    f.association :user_type
    f.sequence(:aleph_bor_status) { |n| n }
    f.sequence(:aleph_bor_type) { |n| n }
  end
end

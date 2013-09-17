FactoryGirl.define do
  factory :address do |f|
    f.sequence(:line1) { |n| "line 1 - #{n}" }
    f.sequence(:line2) { |n| "line 2 - #{n}" }
    f.sequence(:line3) { |n| "line 3 - #{n}" }
    f.zipcode "9998"
    f.cityname "Testcity"
    f.country ""
  end
end

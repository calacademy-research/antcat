FactoryGirl.define do
  factory :tooltip do
    sequence(:key) { |n| "test.key#{n}" }
    sequence(:text) { |n| "Tooltip text #{n}" }
  end
end

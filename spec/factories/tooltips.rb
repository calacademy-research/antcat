FactoryBot.define do
  factory :tooltip do
    sequence(:key) { |n| "test.key#{n}" }
    sequence(:text) { |n| "Tooltip text #{n}" }
    scope "references"
  end
end

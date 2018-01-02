FactoryBot.define do
  factory :journal do
    sequence(:name) { |n| "Ants#{n}" }
  end
end

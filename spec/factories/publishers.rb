FactoryBot.define do
  factory :publisher do
    sequence(:name) { |n| "Wiley #{n}" }
    sequence(:place) { |n| "San Francisco #{n}" }
  end
end

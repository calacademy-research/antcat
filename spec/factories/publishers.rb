FactoryBot.define do
  factory :publisher do
    sequence(:name) { |n| "Wiley #{n}" }
    sequence(:place_name) { |n| "San Francisco #{n}" }
  end
end

FactoryBot.define do
  factory :synonym do
    association :junior_synonym, factory: :genus
    association :senior_synonym, factory: :genus
  end
end

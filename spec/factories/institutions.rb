FactoryGirl.define do
  factory :institution do
    sequence(:abbreviation) { |n| "AS#{n}" }
    sequence(:name) { |n| "Academy of Science #{n}" }

    trait :casc do
      abbreviation 'CASC'
      name 'California Academy of Sciences'
    end
  end
end

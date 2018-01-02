FactoryBot.define do
  factory :issue do
    association :adder, factory: :user
    open true
    title "Check synonyms"
    description "Joffre's brother told me these were synonyms."

    trait :open do
    end

    trait :closed do
      open false
      association :closer, factory: :user
    end
  end
end

FactoryBot.define do
  factory :issue do
    association :adder, factory: :user
    open { true }
    sequence(:title) { |n| "Issue #{n}" }
    sequence(:description) { |n| "About Joffre's issue #{n}" }

    trait :open do
    end

    trait :closed do
      open { false }
      association :closer, factory: :user
    end

    trait :help_wanted do
      help_wanted { true }
    end
  end
end

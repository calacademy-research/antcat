# frozen_string_literal: true

FactoryBot.define do
  factory :issue do
    user
    sequence(:title) { |n| "Issue title #{n}" }
    sequence(:description) { |n| "Issue description #{n}" }

    trait :open

    trait :closed do
      open { false }
      association :closer, factory: :user
    end

    trait :help_wanted do
      help_wanted { true }
    end
  end
end

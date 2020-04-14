# frozen_string_literal: true

FactoryBot.define do
  factory :feedback do
    ip { "127.0.0.1" }
    sequence(:comment) { |n| "Great catalog! For the #{n}th time!" }

    trait :closed do
      open { false }
    end
  end
end

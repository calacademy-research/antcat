# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    user { nil }
    trackable factory: :journal
    action { "create" }

    trait :execute_script do
      trackable { nil }
      action { :execute_script }
    end
  end
end

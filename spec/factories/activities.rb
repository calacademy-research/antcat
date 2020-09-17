# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    trackable factory: :journal
    action { "create" }

    with_user

    trait :with_user do
      user
    end

    trait :execute_script do
      trackable { nil }
      action { :execute_script }
    end
  end
end

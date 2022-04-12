# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    trackable factory: :journal
    event { Activity::CREATE }

    with_user

    trait :with_user do
      user
    end

    trait :execute_script do
      trackable { nil }
      event { Activity::EXECUTE_SCRIPT }
    end

    trait :automated_edit do
      automated_edit { true }
    end
  end
end

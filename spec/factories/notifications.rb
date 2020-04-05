# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    user
    association :notifier, factory: :user
    mentioned_in_thing

    trait :unread

    trait :mentioned_in_thing do
      reason { Notification::MENTIONED_IN_THING }
      association :attached, factory: :site_notice
    end

    trait :active_in_discussion do
      reason { Notification::ACTIVE_IN_DISCUSSION }
      association :attached, factory: :comment
    end
  end
end

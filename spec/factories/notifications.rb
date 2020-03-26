# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    reason { Notification::MENTIONED_IN_THING }
    association :notifier, factory: :user
    association :attached, factory: :site_notice

    trait :unread
  end
end

FactoryBot.define do
  factory :notification do
    reason { "mentioned_in_comment" }
    association :notifier, factory: :user
    association :attached, factory: :site_notice

    trait :unread
  end
end

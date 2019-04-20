FactoryBot.define do
  factory :activity do
    user { nil }
    trackable factory: :journal
    action { "create" }

    trait :custom do
      trackable { nil }
      action { :custom }
    end
  end
end

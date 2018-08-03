FactoryBot.define do
  factory :activity do
    user factory: :user
    trackable factory: :journal
    action "create"

    trait :custom do
      trackable nil
      action :custom
    end
  end
end

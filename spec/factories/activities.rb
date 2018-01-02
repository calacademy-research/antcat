FactoryBot.define do
  factory :activity do
    user factory: :user
    trackable factory: :journal
    action "create"
  end
end

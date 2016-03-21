FactoryGirl.define do
  factory :activity, class: Feed::Activity do
    user factory: :user
    trackable factory: :journal
    action "create"
  end
end

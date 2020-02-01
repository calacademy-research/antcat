FactoryBot.define do
  factory :comment do
    sequence(:body) { |n| "A comment #{n}" }
    user
    association :commentable, factory: :issue
  end
end

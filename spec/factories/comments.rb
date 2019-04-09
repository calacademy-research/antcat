FactoryBot.define do
  factory :comment do
    sequence(:body) { |n| "A comment #{n}" }
    user
    association :commentable, factory: :issue

    trait :reply do
      association :parent, factory: :comment
      sequence(:body) { |n| "OK, makes sense #{n}" }
    end
  end
end

FactoryGirl.define do
  factory :comment do
    body "A comment"
    user
    association :commentable, factory: :issue

    factory :reply do
      association :parent, factory: :comment
      body "OK, makes sense"
    end
  end
end

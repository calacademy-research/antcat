FactoryBot.define do
  factory :user do
    name 'Mark Wilden'
    sequence(:email) { |n| "mark#{n}@example.com" }
    password 'secret'

    trait :superadmin do
      after(:create) { |user| user.add_role :superadmin }
    end

    trait :editor do
      name 'Brian Fisher'
      sequence(:email) { |n| "brian#{n}@example.com" }
      after(:create) { |user| user.add_role :editor }
    end
  end
end

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@antcat.org" }
    password { 'secret' }

    trait :user

    trait :helper do
      helper { true }
    end

    trait :editor do
      editor { true }
    end

    trait :superadmin do
      superadmin { true }
    end
  end
end

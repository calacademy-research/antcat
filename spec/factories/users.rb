FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@antcat.org" }
    password { 'secret' }

    trait :superadmin do
      superadmin { true }
    end

    trait :editor do
      editor { true }
    end

    trait :helper do
      helper { true }
    end
  end
end

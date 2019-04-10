FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@antcat.org" }
    password { 'secret' }

    trait :superadmin do
      is_superadmin { true }
    end

    trait :editor do
      can_edit { true }
    end

    trait :helper do
      is_helper { true }
    end
  end
end

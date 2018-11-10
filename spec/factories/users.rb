FactoryBot.define do
  factory :user do
    name { 'Mark Wilden' }
    sequence(:email) { |n| "mark#{n}@example.com" }
    password { 'secret' }

    trait :superadmin do
      is_superadmin { true }
    end

    trait :editor do
      name { 'Brian Fisher' }
      sequence(:email) { |n| "brian#{n}@example.com" }
      can_edit { true }
    end
  end
end

# frozen_string_literal: true

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

      editor
    end

    trait :developer do
      developer { true }
    end

    trait :disabled_email_notifications do
      enable_email_notifications { false }
    end
  end
end

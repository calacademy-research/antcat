FactoryBot.define do
  factory :user do
    name 'Mark Wilden'
    sequence(:email) { |n| "mark#{n}@example.com" }
    password 'secret'
  end

  factory :editor, class: User do
    name 'Brian Fisher'
    sequence(:email) { |n| "brian#{n}@example.com" }
    password 'secret'
    can_edit true
  end
end

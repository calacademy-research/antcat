# frozen_string_literal: true

FactoryBot.define do
  factory :institution do
    sequence(:abbreviation) { |n| "AS#{n}" }
    sequence(:name) { |n| "Institution #{n}" }

    trait :casc do
      abbreviation { 'CASC' }
      name { 'California Academy of Sciences' }
    end
  end
end

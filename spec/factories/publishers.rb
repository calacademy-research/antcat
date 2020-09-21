# frozen_string_literal: true

FactoryBot.define do
  factory :publisher do
    sequence(:name) { |n| "Publisher #{n}" }
    sequence(:place) { |n| "Place #{n}" }
  end
end

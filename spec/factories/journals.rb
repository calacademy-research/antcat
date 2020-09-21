# frozen_string_literal: true

FactoryBot.define do
  factory :journal do
    sequence(:name) { |n| "Journal #{n}" }
  end
end

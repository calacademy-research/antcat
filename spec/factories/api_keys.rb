# frozen_string_literal: true

FactoryBot.define do
  # A pending registration; `api_key.issue_key!` confirms it and returns the key.
  factory :api_key do
    sequence(:name) { |n| "Researcher #{n}" }
    sequence(:email) { |n| "researcher#{n}@example.org" }
    project { "Checking the names of a regional ant list." }
    terms { true }
  end
end

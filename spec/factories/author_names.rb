# frozen_string_literal: true

FactoryBot.define do
  factory :author_name do
    sequence(:name) { |n| "Fisher#{n}, B.L." }
    author
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :citation do
    reference factory: :any_reference
    sequence(:pages) { |n| n }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :reference_document do
    trait :with_reference do
      reference factory: :any_reference
    end
  end
end

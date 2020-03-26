# frozen_string_literal: true

FactoryBot.define do
  factory :citation do
    reference factory: :article_reference
    sequence(:pages) { |n| n }
  end
end

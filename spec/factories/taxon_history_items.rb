# frozen_string_literal: true

FactoryBot.define do
  factory :taxon_history_item do
    sequence(:taxt) { |n| "history item content #{n}" }
    association :taxon, factory: :family
  end
end

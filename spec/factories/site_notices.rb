# frozen_string_literal: true

FactoryBot.define do
  factory :site_notice do
    sequence(:title) { |n| "Site notice title #{n}" }
    sequence(:message) { |n| "Site notice message #{n}" }
    association :user, factory: :user
  end
end

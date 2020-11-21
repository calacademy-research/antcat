# frozen_string_literal: true

FactoryBot.define do
  factory :tooltip do
    sequence(:key) { |n| "key_#{n}" }
    sequence(:text) { |n| "Tooltip text #{n}" }
    sequence(:scope, 'a') { |n| "scope_#{n}" }
  end
end

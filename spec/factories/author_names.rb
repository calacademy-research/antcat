# frozen_string_literal: true

FactoryBot.define do
  factory :author_name do
    sequence(:name, 'a') { |n| "Author#{n}, A.B." }
    author
  end
end

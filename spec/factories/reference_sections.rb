# frozen_string_literal: true

FactoryBot.define do
  factory :reference_section do
    association :taxon, factory: :family
    sequence(:position) { |n| n }
    sequence(:references_taxt) { |n| "Reference #{n}" }

    trait :with_all_taxts do
      sequence(:title_taxt) { |n| "title_taxt #{n}" }
      sequence(:references_taxt) { |n| "references_taxt #{n}" }
      sequence(:subtitle_taxt) { |n| "subtitle_taxt #{n}" }
    end
  end
end

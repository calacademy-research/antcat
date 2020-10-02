# frozen_string_literal: true

FactoryBot.define do
  factory :reference_section do
    transient do
      taxt_tag {}
    end

    association :taxon, factory: :family
    sequence(:references_taxt) { |n| "references_taxt #{n}" }

    trait :with_all_taxts do
      sequence(:title_taxt) { |n| "title_taxt #{n} #{taxt_tag}" }
      sequence(:references_taxt) { |n| "references_taxt #{n} #{taxt_tag}" }
      sequence(:subtitle_taxt) { |n| "subtitle_taxt #{n} #{taxt_tag}" }
    end
  end
end

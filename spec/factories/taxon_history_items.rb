# frozen_string_literal: true

FactoryBot.define do
  factory :taxon_history_item do
    transient do
      taxt_tag {}
    end

    sequence(:taxt) { |n| "history item content #{n}" }
    association :taxon, factory: :family # TODO: Remove before going live. [grep:proitem].
    association :protonym

    trait :with_all_taxts do
      sequence(:taxt) { |n| "taxt #{n} #{taxt_tag}" }
    end
  end
end

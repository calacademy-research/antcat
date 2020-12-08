# frozen_string_literal: true

FactoryBot.define do
  factory :history_item, class: 'HistoryItem' do
    transient do
      taxt_tag {}
    end

    association :protonym

    taxt

    # Types. [grep:history_type].
    trait :taxt do
      type { HistoryItem::TAXT }
      sequence(:taxt) { |n| "history item content #{n}" }
    end

    # Misc.
    trait :without_taxt do
      taxt { nil }
    end

    trait :with_all_taxts do
      sequence(:taxt) { |n| "taxt #{n} #{taxt_tag}" }
    end
  end
end

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

    trait :type_specimen_designation do
      type { HistoryItem::TYPE_SPECIMEN_DESIGNATION }

      lectotype_designation
    end

    trait :lectotype_designation do
      type { HistoryItem::TYPE_SPECIMEN_DESIGNATION }
      subtype { HistoryItem::LECTOTYPE_DESIGNATION }

      without_taxt
      with_reference
    end

    trait :neotype_designation do
      type { HistoryItem::TYPE_SPECIMEN_DESIGNATION }
      subtype { HistoryItem::NEOTYPE_DESIGNATION }

      without_taxt
      with_reference
    end

    trait :form_descriptions do
      type { HistoryItem::FORM_DESCRIPTIONS }
      text_value { Taxt::StandardHistoryItemFormats::FORMS.sample }

      without_taxt
      with_reference
    end

    trait :combination_in do
      type { HistoryItem::COMBINATION_IN }

      without_taxt
      with_reference
      with_object_protonym
    end

    trait :junior_synonym_of do
      type { HistoryItem::JUNIOR_SYNONYM_OF }

      without_taxt
      with_reference
      with_object_protonym
    end

    trait :senior_synonym_of do
      type { HistoryItem::SENIOR_SYNONYM_OF }

      without_taxt
      with_reference
      with_object_protonym
    end

    trait :status_as_species do
      type { HistoryItem::STATUS_AS_SPECIES }

      without_taxt
      with_reference
    end

    trait :subspecies_of do
      type { HistoryItem::SUBSPECIES_OF }

      without_taxt
      with_reference
      with_object_protonym
    end

    # Type-specific.
    trait :with_pages do
      sequence(:pages) { |n| n }
    end

    trait :with_reference do
      reference factory: :any_reference

      with_pages
    end

    trait :with_1758_reference do
      reference { create :any_reference, year: 1758 }

      with_pages
    end

    trait :with_2000_reference do
      reference { create :any_reference, year: 2000 }

      with_pages
    end

    trait :with_object_protonym do
      object_protonym factory: :protonym
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

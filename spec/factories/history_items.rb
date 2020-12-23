# frozen_string_literal: true

FactoryBot.define do
  factory :history_item, class: 'HistoryItem' do
    transient do
      taxt_tag {}
    end

    association :protonym

    trait :family_rank_only_item do
      rank { Rank::FAMILY }
    end

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

      with_reference
    end

    trait :neotype_designation do
      type { HistoryItem::TYPE_SPECIMEN_DESIGNATION }
      subtype { HistoryItem::NEOTYPE_DESIGNATION }

      with_reference
    end

    trait :form_descriptions do
      type { HistoryItem::FORM_DESCRIPTIONS }
      text_value { Taxt::StandardHistoryItemFormats::FORMS.sample }

      with_reference
    end

    trait :combination_in do
      type { HistoryItem::COMBINATION_IN }

      with_reference
      with_object_taxon
    end

    trait :junior_synonym_of do
      type { HistoryItem::JUNIOR_SYNONYM_OF }

      with_reference
      with_object_protonym
    end

    trait :senior_synonym_of do
      type { HistoryItem::SENIOR_SYNONYM_OF }

      with_reference
      with_object_protonym
    end

    trait :status_as_species do
      type { HistoryItem::STATUS_AS_SPECIES }

      with_reference
    end

    trait :subspecies_of do
      type { HistoryItem::SUBSPECIES_OF }

      with_reference
      with_object_taxon
    end

    trait :replacement_name do
      type { HistoryItem::REPLACEMENT_NAME }

      with_object_protonym
    end

    trait :replacement_name_for do
      type { HistoryItem::REPLACEMENT_NAME_FOR }

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

    trait :with_object_taxon do
      object_taxon factory: :family
    end

    trait :force_author_citation do
      force_author_citation { true }
    end

    # Misc.
    trait :with_all_taxts do
      sequence(:taxt) { |n| "taxt #{n} #{taxt_tag}" }
    end
  end
end

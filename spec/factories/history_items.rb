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
      type { History::Definitions::TAXT }
      sequence(:taxt) { |n| "history item content #{n}" }
    end

    trait :type_specimen_designation do
      type { History::Definitions::TYPE_SPECIMEN_DESIGNATION }

      lectotype_designation
    end

    trait :lectotype_designation do
      type { History::Definitions::TYPE_SPECIMEN_DESIGNATION }
      subtype { History::Definitions::LECTOTYPE_DESIGNATION }

      with_reference
    end

    trait :neotype_designation do
      type { History::Definitions::TYPE_SPECIMEN_DESIGNATION }
      subtype { History::Definitions::NEOTYPE_DESIGNATION }

      with_reference
    end

    trait :form_descriptions do
      type { History::Definitions::FORM_DESCRIPTIONS }
      text_value { Taxt::StandardHistoryItemFormats::FORMS.sample }

      with_reference
    end

    trait :combination_in do
      type { History::Definitions::COMBINATION_IN }

      with_reference
      with_object_taxon
    end

    trait :junior_synonym_of do
      type { History::Definitions::JUNIOR_SYNONYM_OF }

      with_reference
      with_object_protonym
    end

    trait :senior_synonym_of do
      type { History::Definitions::SENIOR_SYNONYM_OF }

      with_reference
      with_object_protonym
    end

    trait :status_as_species do
      type { History::Definitions::STATUS_AS_SPECIES }

      with_reference
    end

    trait :subspecies_of do
      type { History::Definitions::SUBSPECIES_OF }

      with_reference
      with_object_protonym
    end

    trait :homonym_replaced_by do
      type { History::Definitions::HOMONYM_REPLACED_BY }

      with_object_taxon
    end

    trait :replacement_name_for do
      type { History::Definitions::REPLACEMENT_NAME_FOR }

      with_object_taxon
    end

    trait :unavailable_name do
      type { History::Definitions::UNAVAILABLE_NAME }
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

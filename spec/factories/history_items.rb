# frozen_string_literal: true

FactoryBot.define do
  factory :history_item, class: 'HistoryItem' do
    transient do
      taxt_tag {}
    end

    protonym

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

    trait :unavailable_infrasubspecific_name do
      type { History::Definitions::UNAVAILABLE_INFRASUBSPECIFIC_NAME }

      with_reference
    end

    trait :declared_unavailable_infrasubspecific_name do
      type { History::Definitions::DECLARED_UNAVAILABLE_INFRASUBSPECIFIC_NAME }

      with_reference
    end

    trait :first_available_use_unavailable_infrasubspecific do
      type { History::Definitions::FIRST_AVAILABLE_USE_UNAVAILABLE_INFRASUBSPECIFIC }

      with_object_taxon
    end

    trait :also_described_as_new do
      type { History::Definitions::ALSO_DESCRIBED_AS_NEW }

      with_reference
    end

    trait :misspelled_as do
      type { History::Definitions::MISSPELLED_AS }
      text_value { '<i>atrata</i>' }

      with_reference
    end

    trait :incertae_sedis_in do
      type { History::Definitions::INCERTAE_SEDIS_IN }
      subtype { History::Definitions::UNIDENTIFIABLE_TAXON }

      with_reference
      with_object_taxon
    end

    trait :material_referred_to do
      type { History::Definitions::MATERIAL_REFERRED_TO }

      with_reference
      with_object_taxon
    end

    trait :material_of_unavailable_name_referred_here do
      type { History::Definitions::MATERIAL_OF_UNAVAILABLE_NAME_REFERRED_HERE }

      with_reference
      with_object_taxon
    end

    trait :placement_in do
      type { History::Definitions::PLACEMENT_IN }
      taxt { "#{Taxt.tax(create(:family).id)}, #{Taxt.tax(create(:family).id)}" }

      with_reference
    end

    trait :placement_incertae_sedis_in do
      type { History::Definitions::PLACEMENT_INCERTAE_SEDIS_IN }

      with_reference
      with_object_taxon
    end

    trait :as_genus do
      type { History::Definitions::AS_GENUS }

      with_reference
    end

    trait :as_rank_of do
      type { History::Definitions::AS_RANK_OF }
      subtype { 'Subgenus' }

      with_reference
      with_object_taxon
    end

    trait :as_synonym_of do
      type { History::Definitions::AS_SYNONYM_OF }
      subtype { 'Junior' }

      with_reference
      with_object_taxon
    end

    trait :unresolved_junior_homonym_of do
      type { History::Definitions::UNRESOLVED_JUNIOR_HOMONYM_OF }
      subtype { 'Primary' }

      with_object_taxon
    end

    trait :unnecessary_replacement_name_for do
      type { History::Definitions::UNNECESSARY_REPLACEMENT_NAME_FOR }

      with_object_taxon
    end

    trait :unidentifiable_taxon do
      type { History::Definitions::UNIDENTIFIABLE_TAXON }

      with_reference
    end

    trait :subgenus_indeterminate do
      type { History::Definitions::SUBGENUS_INDETERMINATE }

      with_reference
    end

    trait :duplicated_in do
      type { History::Definitions::DUPLICATED_IN }

      with_reference
    end

    trait :nomen_nudum_citation do
      type { History::Definitions::NOMEN_NUDUM_CITATION }
      text_value { '<i>Camponotus maculatus cognatodichrous</i>' }

      with_reference
    end

    trait :subspecies_of do
      type { History::Definitions::SUBSPECIES_OF }

      with_reference
      with_object_protonym
    end

    trait :junior_primary_homonym_of do
      type { History::Definitions::JUNIOR_PRIMARY_HOMONYM_OF }

      with_object_taxon
    end

    trait :junior_primary_homonym_of_hardcoded_genus do
      type { History::Definitions::JUNIOR_PRIMARY_HOMONYM_OF_HARDCODED_GENUS }

      sequence(:text_value, 'a') { |n| "<i>Genus#{n}ii</i>" }
    end

    trait :junior_secondary_homonym_of do
      type { History::Definitions::JUNIOR_SECONDARY_HOMONYM_OF }

      with_object_taxon
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

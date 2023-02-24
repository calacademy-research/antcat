# frozen_string_literal: true

FactoryBot.define do
  factory :protonym do
    transient do
      authorship_reference {}
      protonym_name_string {}
      taxt_tag {}
    end

    before(:create) do |protonym, evaluator|
      if evaluator.protonym_name_string
        protonym.name = protonym.name.class.new(name: evaluator.protonym_name_string)
      end
    end

    authorship do
      if authorship_reference
        association :citation, reference: authorship_reference
      else
        association :citation
      end
    end

    genus_group

    # Rank-related.
    trait :family_group do
      association :name, factory: :family_name
    end

    # NOTE: Subfamily protonyms are 'family-group names' per ICZN (but they have subfamily names).
    trait :family_group_subfamily_name do
      association :name, factory: :subfamily_name
    end

    trait :genus_group do
      association :name, factory: :genus_name
    end

    trait :species_group do
      association :name, factory: :species_name
    end

    # Fossil-related.
    trait :fossil do
      fossil { true }
    end

    trait :ichnotaxon do
      fossil
      ichnotaxon { true }
    end

    # Nomen attributes.
    trait :nomen_nudum do
      nomen_nudum { true }
    end

    # Gender agreement types.
    trait :adjective_gender_agreement_type do
      gender_agreement_type { Protonym::ADJECTIVE }

      species_group
    end

    trait :noun_in_apposition_gender_agreement_type do
      gender_agreement_type { Protonym::NOUN_IN_APPOSITION }

      species_group
    end

    trait :noun_in_genitive_case_gender_agreement_type do
      gender_agreement_type { Protonym::NOUN_IN_GENITIVE_CASE }

      species_group
    end

    trait :participle_gender_agreement_type do
      gender_agreement_type { Protonym::PARTICIPLE }

      species_group
    end

    trait :blank_gender_agreement_type do
      gender_agreement_type { nil }

      species_group
    end

    # Misc.
    trait :with_type_name do
      type_name
    end

    trait :with_all_taxts do
      sequence(:etymology_taxt) { |n| "etymology_taxt #{n} #{taxt_tag}" }
      sequence(:primary_type_information_taxt) { |n| "primary_type_information_taxt #{n} #{taxt_tag}" }
      sequence(:secondary_type_information_taxt) { |n| "secondary_type_information_taxt #{n} #{taxt_tag}" }
      sequence(:type_notes_taxt) { |n| "type_notes_taxt #{n} #{taxt_tag}" }
      sequence(:notes_taxt) { |n| "notes_taxt #{n} #{taxt_tag}" }
    end
  end
end

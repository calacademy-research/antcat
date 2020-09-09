# frozen_string_literal: true

# TODO: Add transient attributes for the authorship to avoid `taxon.protonym.authorship.update`.

FactoryBot.define do
  factory :protonym do
    transient do
      taxt_tag {}
    end

    authorship factory: :citation

    genus_group_name

    trait :fossil do
      fossil { true }
    end

    trait :nomen_nudum do
      nomen_nudum { true }
    end

    trait :uncertain_locality do
      uncertain_locality { true }
    end

    trait :genus_group_name do
      association :name, factory: :genus_name
    end

    trait :species_group_name do
      association :name, factory: :species_name
    end

    trait :with_type_name do
      type_name
    end

    trait :with_all_taxts do
      sequence(:primary_type_information_taxt) { |n| "primary_type_information_taxt #{n} #{taxt_tag}" }
      sequence(:secondary_type_information_taxt) { |n| "secondary_type_information_taxt #{n} #{taxt_tag}" }
      sequence(:type_notes_taxt) { |n| "type_notes_taxt #{n} #{taxt_tag}" }
      sequence(:notes_taxt) { |n| "notes_taxt #{n} #{taxt_tag}" }
    end
  end
end

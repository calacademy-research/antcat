# frozen_string_literal: true

# TODO: Add transient attributes for the authorship to avoid `taxon.protonym.authorship.update`.

FactoryBot.define do
  factory :protonym do
    authorship factory: :citation
    genus_group_name

    trait :fossil do
      fossil { true }
    end

    trait :genus_group_name do
      association :name, factory: :genus_name
    end

    trait :species_group_name do
      association :name, factory: :species_name
    end

    trait :with_taxts do
      sequence(:primary_type_information_taxt) { |n| "primary_type_information_taxt #{n}" }
      sequence(:secondary_type_information_taxt) { |n| "secondary_type_information_taxt #{n}" }
      sequence(:type_notes_taxt) { |n| "type_notes_taxt #{n}" }
    end
  end
end

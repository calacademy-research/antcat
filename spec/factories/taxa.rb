# frozen_string_literal: true

# TODO: Names are randomly generated for associated ranks (for example
# the genus epithet of a species does not always agree with its genus' epithet).

FactoryBot.define do
  factory :base_taxon, class: 'Taxon' do
    transient do
      name_string {}
    end

    before(:create) do |taxon, evaluator|
      if evaluator.name_string
        taxon.name = taxon.name_class.new(name: evaluator.name_string)
      end
    end

    valid

    factory :family, class: Rank::FAMILY.to_s, aliases: [:any_taxon] do
      association :name, factory: :family_name

      genus_group_protonym

      trait :formicidae do
        name_string { "Formicidae" }
      end
    end

    factory :subfamily, class: Rank::SUBFAMILY.to_s do
      association :name, factory: :subfamily_name

      genus_group_protonym
      without_family

      trait :with_family do
        family
      end

      trait :without_family do
        family { nil }
      end
    end

    factory :tribe, class: Rank::TRIBE.to_s do
      association :name, factory: :tribe_name
      subfamily

      genus_group_protonym
    end

    factory :subtribe, class: Rank::SUBTRIBE.to_s do
      association :name, factory: :subtribe_name
      tribe

      genus_group_protonym
    end

    factory :genus, class: Rank::GENUS.to_s do
      association :name, factory: :genus_name
      tribe
      subfamily { |taxon| taxon.tribe&.subfamily }

      genus_group_protonym

      trait :incertae_sedis_in_family do
        incertae_sedis_in { Rank::FAMILY }
        subfamily { nil }
      end

      trait :incertae_sedis_in_subfamily do
        incertae_sedis_in { Rank::SUBFAMILY }
      end
    end

    factory :subgenus, class: Rank::SUBGENUS.to_s do
      association :name, factory: :subgenus_name
      genus

      genus_group_protonym
    end

    factory :species, class: Rank::SPECIES.to_s do
      association :name, factory: :species_name
      genus

      species_group_protonym

      trait :incertae_sedis_in_family do
        incertae_sedis_in { Rank::FAMILY }
        subfamily { nil }
      end
    end

    factory :subspecies, class: Rank::SUBSPECIES.to_s do
      association :name, factory: :subspecies_name
      species
      genus

      species_group_protonym
    end

    factory :infrasubspecies, class: Rank::INFRASUBSPECIES.to_s do
      association :name, factory: :infrasubspecies_name
      subspecies
      species
      genus

      species_group_protonym
      unavailable
    end

    # Statuses.
    trait :valid do
      status { Status::VALID }
    end

    trait :synonym do
      status { Status::SYNONYM }

      with_current_taxon
    end

    trait :homonym do
      status { Status::HOMONYM }
      homonym_replaced_by { Family.first || FactoryBot.create(:family) }
    end

    trait :obsolete_combination do
      status { Status::OBSOLETE_COMBINATION }

      with_current_taxon
    end

    trait :unidentifiable do
      status { Status::UNIDENTIFIABLE }
    end

    trait :unavailable do
      status { Status::UNAVAILABLE }
    end

    trait :excluded_from_formicidae do
      status { Status::EXCLUDED_FROM_FORMICIDAE }
    end

    trait :unavailable_misspelling do
      status { Status::UNAVAILABLE_MISSPELLING }
    end

    # Parallel statuses.
    trait :unresolved_homonym do
      unresolved_homonym { true }
    end

    trait :original_combination do
      original_combination { true }
    end

    trait :collective_group_name do
      collective_group_name { true }
    end

    # Misc.
    trait :with_current_taxon do
      current_taxon { Family.first || FactoryBot.create(:family) }
    end

    trait :with_history_item do
      after :create do |taxon|
        create :history_item, :taxt, protonym: taxon.protonym
      end
    end

    trait :genus_group_protonym do
      association :protonym, :genus_group
    end

    trait :species_group_protonym do
      association :protonym, :species_group
    end
  end
end

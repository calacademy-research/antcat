# TODOs:
# * Factories creates too many objects and they seem to create new associations
#   even when passed existing objects.
#
#   Creating a taxon of a lower rank creates all the taxa above it as specified
#   by the factories. This also create objects for their dependencies, such
#   as the protonym, which in turn creates a new citation --> another reference
#   --> another author --> etc etc = many objects.
#
# * Investigate if using (tested) fixtures makes sense for the most-often created objects.
#
# * Investigate reusing more objects, such as always reusing the protonym and journal.
#
# See also `RefactorTaxonFactoriesHelpers`.

require_relative '../support/helpers/get_name_parts_helpers'

FactoryGirl.define do
  factory :taxon do
    protonym
    status 'valid'

    trait :synonym do
      status 'synonym'
    end

    factory :family, class: Family do
      association :name, factory: :family_name
      association :type_name, factory: :genus_name
    end

    factory :subfamily, class: Subfamily do
      association :name, factory: :subfamily_name
      association :type_name, factory: :genus_name
    end

    factory :tribe, class: Tribe do
      association :name, factory: :tribe_name
      association :type_name, factory: :genus_name
      subfamily
    end

    # FIX? Broken. The are 8 SubtribeName:s in the prod db, but no
    # Subtribe:s, so low-priority.
    factory :subtribe, class: Subtribe do
      association :name, factory: :subtribe_name
      association :type_name, factory: :genus_name
      subfamily
    end

    factory :genus, class: Genus do
      association :name, factory: :genus_name
      association :type_name, factory: :species_name
      tribe
      subfamily { |a| a.tribe && a.tribe.subfamily }
    end

    factory :subgenus, class: Subgenus do
      association :name, factory: :subgenus_name
      association :type_name, factory: :species_name
      genus
    end

    factory :species_group_taxon, class: SpeciesGroupTaxon do
      association :name, factory: :species_name
      genus
    end

    factory :species, class: Species do
      association :name, factory: :species_name
      genus
    end

    factory :subspecies, class: Subspecies do
      association :name, factory: :species_name
      species
      genus
    end
  end
end

def create_subfamily name_or_attributes = 'Dolichoderinae', attributes = {}
  _create_taxon name_or_attributes, :subfamily, attributes
end

def create_tribe name_or_attributes = 'Attini', attributes = {}
  _create_taxon name_or_attributes, :tribe, attributes
end

def create_genus name_or_attributes = 'Atta', attributes = {}
  _create_taxon name_or_attributes, :genus, attributes
end

def create_subgenus name_or_attributes = 'Atta (Subatta)', attributes = {}
  _create_taxon name_or_attributes, :subgenus, attributes
end

def create_species name_or_attributes = 'Atta major', attributes = {}
  _create_taxon name_or_attributes, :species, attributes
end

def create_subspecies name_or_attributes = 'Atta major minor', attributes = {}
  _create_taxon name_or_attributes, :subspecies, attributes
end

def _create_taxon name_or_attributes, rank, attributes = {}
  taxon_factory = rank
  name_factory = "#{rank}_name".to_sym

  attributes =
    if name_or_attributes.kind_of? String
      name, epithet, epithets = GetNamePartsHelpers.get_name_parts name_or_attributes
      name_object = create name_factory, name: name, epithet: epithet, epithets: epithets
      attributes.reverse_merge name: name_object, name_cache: name
    else
      name_or_attributes
    end

  FactoryGirl.create taxon_factory, attributes
end

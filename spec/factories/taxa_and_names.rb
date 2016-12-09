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

FactoryGirl.define do
  factory :name do
    sequence(:name) { |n| raise }
    name_html { name }
    epithet { name }
    epithet_html { name_html }

    factory :family_name, class: FamilyName do
      name 'Formicidae'
    end

    factory :subfamily_name, class: SubfamilyName do
      sequence(:name) { |n| "Subfamily#{n}" }
    end

    factory :tribe_name, class: TribeName do
      sequence(:name) { |n| "Tribe#{n}" }
    end

    factory :subtribe_name, class: SubtribeName do
      sequence(:name) { |n| "Subtribe#{n}" }
    end

    factory :genus_name, class: GenusName do
      sequence(:name) { |n| "Genus#{n}" }
      name_html { "<i>#{name}</i>" }
      epithet_html { "<i>#{name}</i>" }
    end

    # TODO possibly broken
    # from prod db
    # Subgenus.first.name.name_html # "<i>Lasius</i> <i>(Acanthomyops)</i>"
    #
    # from
    # $rails console test --sandbox
    # SunspotTest.stub
    # FactoryGirl.create :subgenus
    # Subgenus.first.name.name_html # "<i>Atta</i> <i>(Atta (Subgenus2))</i>"
    factory :subgenus_name, class: SubgenusName do
      sequence(:name) { |n| "Atta (Subgenus#{n})" }
      name_html { "<i>Atta</i> <i>(#{name})</i>" }
      epithet { name.split(' ').last }
      epithet_html { "<i>#{epithet}</i>" }
    end

    factory :species_name, class: SpeciesName do
      sequence(:name) { |n| "Atta species#{n}" }
      name_html { "<i>#{name}</i>" }
      epithet { name.split(' ').last }
      epithet_html { "<i>#{epithet}</i>" }
    end

    factory :subspecies_name, class: SubspeciesName do
      sequence(:name) { |n| "Atta species subspecies#{n}" }
      name_html { "<i>#{name}</i>" }
      epithet { name.split(' ').last }
      epithets { name.split(' ')[-2..-1].join(' ') }
      epithet_html { "<i>#{epithet}</i>" }
    end
  end

  factory :taxon do
    association :name, factory: :genus_name
    association :type_name, factory: :species_name
    protonym
    status 'valid'

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

def create_family
  _create_taxon 'Formicidae', :family
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
      name, epithet, epithets = get_name_parts name_or_attributes
      name_object = create name_factory, name: name, epithet: epithet, epithets: epithets
      attributes.reverse_merge name: name_object, name_cache: name
    else
      name_or_attributes
    end

  build_stubbed = attributes.delete :build_stubbed
  build = attributes.delete :build
  build_stubbed ||= build
  FactoryGirl.send(build_stubbed ? :build_stubbed : :create, taxon_factory, attributes)
end

def get_name_parts name
  parts = name.split ' '
  epithet = parts.last
  epithets = parts[1..-1].join(' ') unless parts.size < 2
  return name, epithet, epithets
end

def find_or_create_name name
  name, epithet, epithets = get_name_parts name
  create :name, name: name, epithet: epithet, epithets: epithets
end

def create_species_name name
  name, epithet, epithets = get_name_parts name
  create :species_name, name: name, epithet: epithet, epithets: epithets
end

def create_subspecies_name name
  name, epithet, epithets = get_name_parts name
  create :subspecies_name, name: name, epithet: epithet, epithets: epithets
end

# Mimics `TaxaController#build_new_taxon` to avoid interference from the factories.
def build_new_taxon rank
  taxon_class = "#{rank}".titlecase.constantize

  taxon = taxon_class.new
  taxon.build_name
  taxon.build_type_name
  taxon.build_protonym
  taxon.protonym.build_name
  taxon.protonym.build_authorship
  taxon
end

def build_new_taxon_and_set_parent rank, parent
  taxon = build_new_taxon rank
  taxon.parent = parent
  taxon
end

# New set of light factories because FactoryGirl does too much and some factories are bugged.
# TODO refactor and merge.
def build_minimal_family
  name = FamilyName.new name: "Formicidae"
  protonym = Protonym.first || minimal_protonym
  Family.new name: name, protonym: protonym
end

def minimal_family
  build_minimal_family.tap &:save
end

def minimal_subfamily
  name = SubfamilyName.new name: "Minimalinae"
  protonym = Protonym.first || minimal_protonym
  Subfamily.new(name: name, protonym: protonym).tap &:save
end

def minimal_protonym
  reference = UnknownReference.new citation: "book", citation_year: 2000, title: "Ants plz"
  citation = Citation.new reference: reference
  name = Name.new name: "name"

  Protonym.new name: name, authorship: citation
end

def an_old_taxon
  taxon = minimal_family
  taxon.taxon_state.update_columns review_state: :old
  taxon.reload
  taxon
end

def old_family_and_subfamily
  family = an_old_taxon

  subfamily = minimal_subfamily
  subfamily.family = family
  subfamily.save
  subfamily.taxon_state.update_columns review_state: :old
  subfamily.reload

  # Confirm.
  expect(family).to be_old
  expect(subfamily.family).to eq family
  expect(subfamily).to be_old

  [family, subfamily]
end

def mark_as_auto_generated objects
  Array.wrap(objects)
    .each { |object| object.update_columns auto_generated: true }
    .each { |object| expect(object).to be_auto_generated }
end

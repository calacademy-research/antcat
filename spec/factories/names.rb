require_relative '../support/helpers/get_name_parts_helpers'
include GetNamePartsHelpers

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

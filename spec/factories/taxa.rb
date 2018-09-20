FactoryBot.define do
  factory :taxon do
    protonym
    valid

    trait :valid do
      status Status::VALID
    end

    trait :synonym do
      status Status::SYNONYM
      with_current_valid_taxon
    end

    trait :homonym do
      status Status::HOMONYM
    end

    trait :original_combination do
      status Status::ORIGINAL_COMBINATION
      with_current_valid_taxon
    end

    trait :unidentifiable do
      status Status::UNIDENTIFIABLE
    end

    trait :unavailable do
      status Status::UNAVAILABLE
    end

    trait :excluded_from_formicidae do
      status Status::EXCLUDED_FROM_FORMICIDAE
    end

    trait :fossil do
      fossil true
    end

    trait :with_current_valid_taxon do
      current_valid_taxon { Family.first || FactoryBot.create(:family) }
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

    trait :old do
      association :taxon_state, review_state: TaxonState::OLD
    end

    trait :waiting do
      association :taxon_state, review_state: TaxonState::WAITING
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
    if name_or_attributes.is_a? String
      name, epithet, epithets = get_name_parts name_or_attributes
      name_object = create name_factory, name: name, epithet: epithet, epithets: epithets
      attributes.reverse_merge name: name_object, name_cache: name
    else
      name_or_attributes
    end

  FactoryBot.create taxon_factory, attributes
end

def get_name_parts name
  parts = name.split ' '
  epithet = parts.last
  epithets = parts[1..-1].join(' ') unless parts.size < 2
  [name, epithet, epithets]
end

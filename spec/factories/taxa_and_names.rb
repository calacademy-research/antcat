FactoryGirl.define do
  factory :name do
    sequence(:name) { |n| raise }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :family_or_subfamily_name do
    name 'FamilyOrSubfamily'
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :family_name do
    name 'Family'
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :subfamily_name do
    sequence(:name) { |n| "Subfamily#{n}" }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :tribe_name do
    sequence(:name) { |n| "Tribe#{n}" }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :subtribe_name do
    sequence(:name) { |n| "Subtribe#{n}" }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :genus_name do
    sequence(:name) { |n| "Genus#{n}" }
    name_html { "<i>#{name}</i>" }
    epithet { name }
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
  factory :subgenus_name do
    sequence(:name) { |n| "Atta (Subgenus#{n})" }
    name_html { "<i>Atta</i> <i>(#{name})</i>" }
    epithet { name.split(' ').last }
    epithet_html { "<i>#{epithet}</i>" }
  end

  factory :species_name do
    sequence(:name) { |n| "Atta species#{n}" }
    name_html { "<i>#{name}</i>" }
    epithet { name.split(' ').last }
    epithet_html { "<i>#{epithet}</i>" }
  end

  factory :subspecies_name do
    sequence(:name) { |n| "Atta species subspecies#{n}" }
    name_html { "<i>#{name}</i>" }
    epithet { name.split(' ').last }
    epithets { name.split(' ')[-2..-1].join(' ') }
    epithet_html { "<i>#{epithet}</i>" }
  end

  factory :taxon do
    after :create do |taxon|
      create(:taxon_state, taxon_id: taxon.id)
      taxon.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }

    association :name, factory: :genus_name
    association :type_name, factory: :species_name
    protonym
    status 'valid'
  end

  factory :family do
    after :create do |family|
      create(:taxon_state, taxon_id: family.id)
      family.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }

    association :name, factory: :family_name
    association :type_name, factory: :genus_name
    protonym
    status 'valid'
  end

  factory :subfamily do
    after :create do |subfamily|
      create(:taxon_state, taxon_id: subfamily.id)
      subfamily.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }

    association :name, factory: :subfamily_name
    association :type_name, factory: :genus_name
    protonym
    status 'valid'
  end

  factory :tribe do
    after :create do |tribe|
      create(:taxon_state, taxon_id: tribe.id)
      tribe.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :tribe_name
    association :type_name, factory: :genus_name
    subfamily
    protonym
    status 'valid'
  end

  # FIX? Broken. The are 8 SubtribeName:s in the prod db, but no
  # Subtribe:s, so low-priority.
  factory :subtribe do
    after :create do |subtribe|
      create(:taxon_state, taxon_id: subtribe.id)
      subtribe.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :subtribe_name
    association :type_name, factory: :genus_name
    subfamily
    protonym
    status 'valid'
  end

  factory :genus do
    after :create do |genus|
      create(:taxon_state, taxon_id: genus.id)
      genus.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :genus_name
    association :type_name, factory: :species_name
    tribe
    subfamily { |a| a.tribe && a.tribe.subfamily }
    protonym
    status 'valid'
  end

  factory :subgenus do
    after :create do |subgenus|
      create(:taxon_state, taxon_id: subgenus.id)
      subgenus.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :subgenus_name
    association :type_name, factory: :species_name
    genus
    protonym
    status 'valid'
  end

  factory :species_group_taxon do
    after :create do |species_group_taxon|
      create(:taxon_state, taxon_id: species_group_taxon.id)
      species_group_taxon.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :species_name
    genus
    protonym
    status 'valid'
  end

  factory :species do
    after :create do |species|
      create(:taxon_state, taxon_id: species.id)
      species.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :species_name
    genus
    protonym
    status 'valid'
  end

  factory :subspecies do
    after :create do |subspecies|
      create(:taxon_state, taxon_id: subspecies.id)
      subspecies.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :species_name
    species
    genus
    protonym
    status 'valid'
  end
end

def create_family
  create_taxon_object 'Formicidae', :family, :family_name
end

def create_subfamily name_or_attributes = 'Dolichoderinae', attributes = {}
  create_taxon_object name_or_attributes, :subfamily, :subfamily_name, attributes
end

def create_tribe name_or_attributes = 'Attini', attributes = {}
  create_taxon_object name_or_attributes, :tribe, :tribe_name, attributes
end

def create_taxon name_or_attributes = 'Atta', attributes = {}
  create_taxon_object name_or_attributes, :genus, :genus_name, attributes
end

def create_genus name_or_attributes = 'Atta', attributes = {}
  create_taxon_object name_or_attributes, :genus, :genus_name, attributes
end

def create_subgenus name_or_attributes = 'Atta (Subatta)', attributes = {}
  create_taxon_object name_or_attributes, :subgenus, :subgenus_name, attributes
end

def create_species name_or_attributes = 'Atta major', attributes = {}
  create_taxon_object name_or_attributes, :species, :species_name, attributes
end

def create_subspecies name_or_attributes = 'Atta major minor', attributes = {}
  create_taxon_object name_or_attributes, :subspecies, :subspecies_name, attributes
end

def create_taxon_object name_or_attributes, taxon_factory, name_factory, attributes = {}
  if name_or_attributes.kind_of? String
    name, epithet, epithets = get_name_parts name_or_attributes
    attributes = attributes.reverse_merge name: create(name_factory, name: name, epithet: epithet, epithets: epithets), name_cache: name
  else
    attributes = name_or_attributes
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

def create_synonym senior, attributes = {}
  junior = create_genus attributes.merge status: 'synonym'
  synonym = Synonym.create! senior_synonym: senior, junior_synonym: junior
  junior
end

def create_taxon_with_state taxon_type, name
  taxon = create taxon_type, name: name
  create :taxon_state, taxon_id: taxon.id
  taxon.touch_with_version
  taxon
end

def create_taxon_version_and_change review_state, user = @user, approver = nil, genus_name = 'default_genus'
  name = create :name, name: genus_name
  taxon = create :genus, name: name
  taxon.taxon_state.review_state = review_state

  change = create :change, user_changed_taxon_id: taxon.id, change_type: "create"
  create :version, item_id: taxon.id, whodunnit: user.id, change_id: change.id

  unless approver.nil?
    change.update_attributes! approver: approver, approved_at: Time.now if approver
  end

  taxon
end

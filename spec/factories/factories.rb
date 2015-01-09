# coding: UTF-8
def reference_factory attributes = {}
  name = attributes.delete :author_name
  author_name = AuthorName.find_by_name name
  author_name ||= FactoryGirl.create :author_name, name: name
  reference = FactoryGirl.create(:reference, attributes.merge(:author_names => [author_name]))
  reference
end

FactoryGirl.define do

  factory :author

  factory :author_name do
    sequence(:name) {|n| "Fisher#{n}, B.L."}
    author
  end

  factory :journal do
    sequence(:name) {|n| "Ants#{n}"}
  end

  factory :publisher do
    name  'Wiley'
    place
  end

  factory :place do
    name  'New York'
  end

  factory :reference do
    sequence(:title)          {|n| "Ants are my life#{n}"}
    sequence(:citation_year)  {|n| "201#{n}d"}
    author_names              {[FactoryGirl.create(:author_name)]}
  end

  factory :article_reference do
    author_names                    {[FactoryGirl.create(:author_name)]}
    sequence(:title)                {|n| "Ants are my life#{n}"}
    sequence(:citation_year)        {|n| "201#{n}d"}
    journal
    sequence(:series_volume_issue)  {|n| n}
    sequence(:pagination)           {|n| n}
  end

  factory :book_reference do
    author_names                    {[FactoryGirl.create(:author_name)]}
    sequence(:title)                {|n| "Ants are my life#{n}"}
    sequence(:citation_year)        {|n| "201#{n}d"}
    publisher
    pagination                      '22 pp.'
  end

  factory :unknown_reference do
    author_names                    {[FactoryGirl.create(:author_name)]}
    sequence(:title)                {|n| "Ants are my life#{n}"}
    sequence(:citation_year)        {|n| "201#{n}d"}
    citation                        'New York'
  end

  factory :missing_reference do
    title         '(missing)'
    citation_year '2009'
    citation      'Latreille, 2009'
  end

  factory :nested_reference do
    author_names              {[FactoryGirl.create(:author_name)]}
    sequence(:title)          {|n| "Nested ants #{n}"}
    sequence(:citation_year)  {|n| "201#{n}d"}
    pages_in                  'In: '
    nesting_reference         {FactoryGirl.create :book_reference}
  end

  factory :user do
    name      'Mark Wilden'
    sequence(:email) {|n| "mark#{n}@example.com"}
    password  'secret'
  end

  factory :editor, class: User do
    name      'Brian Fisher'
    sequence(:email) {|n| "brian#{n}@example.com"}
    password  'secret'
  end

  factory :bolton_reference, :class => Bolton::Reference do
    title 'New General Catalog'
    citation_year '2011'
    authors 'Fisher, B.L.'
  end

  factory :bolton_match, :class => Bolton::Match do
    bolton_reference
    reference
    similarity 0.9
  end

  factory :reference_document do
  end

  factory :synonym do
    association :junior_synonym, factory: :genus
    association :senior_synonym, factory: :genus
  end

  factory :reference_author_name do
    association :reference
    association :author_name
  end

  ####################################################
  factory :name do
    sequence(:name) {|n| raise}
    name_html       {name}
    epithet         {name}
    epithet_html    {name_html}
   end

  factory :family_or_subfamily_name do
    name 'FamilyOrSubfamily'
    name_html       {name}
    epithet         {name}
    epithet_html    {name_html}
  end

  factory :family_name do
    name            'Family'
    name_html       {name}
    epithet         {name}
    epithet_html    {name_html}
  end

  factory :subfamily_name do
    sequence(:name) {|n| "Subfamily#{n}"}
    name_html       {name}
    epithet         {name}
    epithet_html    {name_html}
  end

  factory :tribe_name do
    sequence(:name) {|n| "Tribe#{n}"}
    name_html       {name}
    epithet         {name}
    epithet_html    {name_html}
  end

  factory :subtribe_name do
    sequence(:name) {|n| "Subtribe#{n}"}
    name_html       {name}
    epithet         {name}
    epithet_html    {name_html}
  end

  factory :genus_name do
    sequence(:name) {|n| "Genus#{n}"}
    name_html       {"<i>#{name}</i>"}
    epithet         {name}
    epithet_html    {"<i>#{name}</i>"}
  end

  factory :subgenus_name do
    sequence(:name) {|n| "Atta (Subgenus#{n})"}
    name_html       {"<i>Atta</i> <i>(#{name})</i>"}
    epithet         {name.split(' ').last}
    epithet_html    {"<i>#{epithet}</i>"}
  end

  factory :species_name do
    sequence(:name) {|n| "Atta species#{n}"}
    name_html       {"<i>#{name}</i>"}
    epithet         {name.split(' ').last}
    epithet_html    {"<i>#{epithet}</i>"}
    protonym_html   {name_html}
  end

  factory :subspecies_name do
    sequence(:name) {|n| "Atta species subspecies#{n}"}
    name_html       {"<i>#{name}</i>"}
    epithet         {name.split(' ').last}
    epithets        {name.split(' ')[-2..-1].join(' ')}
    epithet_html    {"<i>#{epithet}</i>"}
    protonym_html   {name_html}
  end

  ####################################################

  factory :taxon do
    association :name, factory: :genus_name
    association :type_name, factory: :species_name
    protonym
    status  'valid'
  end

  factory :family do
    association :name, factory: :family_name
    association :type_name, factory: :genus_name
    protonym
    status  'valid'
  end

  factory :subfamily do
    association :name, factory: :subfamily_name
    association :type_name, factory: :genus_name
    protonym
    status  'valid'
  end

  factory :tribe do
    association :name, factory: :tribe_name
    association :type_name, factory: :genus_name
    subfamily
    protonym
    status  'valid'
  end

  factory :subtribe do
    association :name, factory: :subtribe_name
    association :type_name, factory: :genus_name
    subfamily
    protonym
    status  'valid'
  end

  factory :genus do
    association :name, factory: :genus_name
    association :type_name, factory: :species_name
    tribe
    subfamily   {|a| a.tribe && a.tribe.subfamily}
    protonym
    status  'valid'
  end

  factory :subgenus do
    association :name, factory: :subgenus_name
    association :type_name, factory: :species_name
    genus
    protonym
    status  'valid'
  end

  factory :species_group_taxon do
    association :name, factory: :species_name
    genus
    protonym
    status  'valid'
  end

  factory :species do
    association :name, factory: :species_name
    genus
    protonym
    status  'valid'
  end

  factory :subspecies do
    association :name, factory: :species_name
    species
    genus
    protonym
    status  'valid'
  end

  ####################################################
  factory :citation do
    reference :factory => :article_reference
    pages '49'
  end

  factory :protonym do
    authorship factory: :citation
    association :name, factory: :genus_name
  end

  factory :taxon_history_item, class: TaxonHistoryItem do
    taxt 'Taxonomic history'
  end

  ####################################################
  factory :reference_section do
    association :taxon
    sequence(:position) {|n| n}
    sequence(:references_taxt) {|n| "Reference #{n}"}
  end

  ####################################################
  factory :antwiki_valid_taxon do
  end

  ####################################################
  factory :version do
    item_type 'Taxon'
    event     'create'
    association :whodunnit, factory: :user
  end

  factory :transaction do
    association :paper_trail_version, factory: :version
    association :change
  end

  factory :change do
    change_type     "add"
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
    attributes = attributes.reverse_merge name: FactoryGirl.create(name_factory, name: name, epithet: epithet, epithets: epithets), name_cache: name
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

def create_name name
  name, epithet, epithets = get_name_parts name
  FactoryGirl.create :name, name: name, epithet: epithet, epithets: epithets
end

def create_species_name name
  name, epithet, epithets = get_name_parts name
  FactoryGirl.create :species_name, name: name, epithet: epithet, epithets: epithets
end

def create_subspecies_name name
  name, epithet, epithets = get_name_parts name
  FactoryGirl.create :subspecies_name, name: name, epithet: epithet, epithets: epithets
end

def create_synonym senior, attributes = {}
  junior = create_genus attributes.merge status: 'synonym'
  synonym = Synonym.create! senior_synonym: senior, junior_synonym: junior
  junior
end

def create_taxon_version_and_change review_state, user = @user, approver = nil
  taxon = FactoryGirl.create :genus, review_state: review_state
  change = FactoryGirl.build :change, user_changed_taxon_id: taxon.id
  version = FactoryGirl.build :version, item_id: taxon.id, whodunnit: user
  FactoryGirl.create :transaction, paper_trail_version: version, change: change
  change.update_attributes! approver: approver, approved_at: Time.now if approver
  taxon




  # taxon = FactoryGirl.create :genus, review_state: review_state
  # taxon.last_version.update_attributes! whodunnit: user
  # change = Change.create! paper_trail_version: taxon.last_version
  # change.update_attributes! approver: approver, approved_at: Time.now if approver
  # taxon

  # genus = create_genus name, review_state: :waiting
  # change = FactoryGirl.build :change, user_changed_taxon_id: genus.id
  # version = FactoryGirl.build :version, item_id: genus.id
  # FactoryGirl.create :transaction, paper_trail_version: version, change: change

end

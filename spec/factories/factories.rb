# coding: UTF-8
def reference_factory attributes = {}
  author_name = FactoryGirl.create(:author_name, :name => attributes.delete(:author_name))
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
    author_names                    {[FactoryGirl.create(:author_name)]}
    sequence(:title)                {|n| "Ants are my life#{n}"}
    sequence(:citation_year)        {|n| "201#{n}d"}
    pages_in                        'In: '
    nested_reference                {FactoryGirl.create :book_reference}
  end

  factory :user do
    sequence(:email) {|n| "mark#{n}@example.com"}
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

  ####################################################
  factory :name do
    sequence(:name) {|n| raise; "Name#{n}"}
    html_name       {name}
    epithet         {name}
    html_epithet    {html_name}
  end

  factory :family_or_subfamily_name do
    name 'FamilyOrSubfamily'
    html_name       {name}
    epithet         {name}
    html_epithet    {html_name}
  end

  factory :family_name do
    name 'Family'
    html_name       {name}
    epithet         {name}
    html_epithet    {html_name}
  end

  factory :subfamily_name do
    sequence(:name) {|n| "Subfamily#{n}"}
    html_name       {name}
    epithet         {name}
    html_epithet    {html_name}
  end

  factory :tribe_name do
    sequence(:name) {|n| "Tribe#{n}"}
    html_name       {name}
    epithet         {name}
    html_epithet    {html_name}
  end

  factory :subtribe_name do
    sequence(:name) {|n| "Subtribe#{n}"}
    html_name       {name}
    epithet         {name}
    html_epithet    {html_name}
  end

  factory :genus_group_name do
    sequence(:name) {|n| "GenusGroup#{n}"}
    html_name       {"<i>#{name}</i>"}
    epithet         {name}
    html_epithet    {html_name}
  end

  factory :genus_name do
    sequence(:name) {|n| "Genus#{n}"}
    html_name       {"<i>#{name}</i>"}
    epithet         {name}
    html_epithet    {"<i>#{name}</i>"}
  end

  factory :subgenus_name do
    sequence(:name) {|n| "Atta (Subgenus#{n})"}
    html_name       {"<i>Atta</i> <i>(#{name})</i>"}
    epithet         {name.match(/\((.*)\)/)[1]}
    html_epithet    {"<i>#{epithet}</i>"}
  end

  factory :species_name do
    sequence(:name) {|n| "Atta species#{n}"}
    html_name       {"<i>#{name}</i>"}
    epithet         {name.match(/Atta (.*)/)[1]}
    html_epithet    {"<i>#{epithet}</i>"}
  end

  factory :subspecies_name do
    sequence(:name) {|n| "Atta species subspecies#{n}"}
    html_name       {"<i>#{name}</i>"}
    epithet         {name.match(/Atta species (.*)/)[1]}
    html_epithet    {"<i>#{epithet}</i>"}
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

  factory :species do
    association :name, factory: :species_name
    genus
    protonym
    status  'valid'
  end

  factory :subspecies do
    association :name, factory: :species_name
    species
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

  factory :taxonomic_history_item do
    taxt 'Taxonomic history'
  end

end

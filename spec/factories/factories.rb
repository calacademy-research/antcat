# coding: UTF-8
def reference_factory attributes = {}
  author_name = FactoryGirl.create(:author_name, :name => attributes.delete(:author_name))
  reference = FactoryGirl.create(:reference, attributes.merge(:author_names => [author_name]))
  reference
end

def name_factory name, other_attributes = {}
  {name_object: Name.create(name: name)}.merge other_attributes
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
  factory :name_object, class: Name do
    name 'foo'
  end

  ####################################################

  factory :taxon do
    name_object
    protonym
    status  'valid'
  end

  factory :family do
    name_object
    protonym
    status  'valid'
  end

  factory :subfamily do
    name_object
    protonym
    status  'valid'
  end

  factory :tribe do
    name_object
    subfamily
    protonym
    status  'valid'
  end

  factory :genus do
    name_object
    tribe
    subfamily   {|a| a.tribe && a.tribe.subfamily}
    protonym
    status  'valid'
  end

  factory :subgenus do
    name_object
    genus
    protonym
    status  'valid'
  end

  factory :species do
    name_object
    genus
    protonym
    status  'valid'
  end

  factory :subspecies do
    name_object
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
    name_object
  end

  factory :taxonomic_history_item do
    taxt 'Taxonomic history'
  end

end

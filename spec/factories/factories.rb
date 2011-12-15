# coding: UTF-8

Factory.define :missing_reference do |reference|
  reference.citation "Bolton, 2005"
  reference.citation_year '2001'
  reference.title '(missing)'
end

def reference_factory attributes = {}
  author_name = Factory(:author_name, :name => attributes.delete(:author_name))
  reference = Factory(:reference, attributes.merge(:author_names => [author_name]))
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
    author_names              {[Factory(:author_name)]}
  end

  factory :article_reference do
    author_names                    {[Factory(:author_name)]}
    sequence(:title)                {|n| "Ants are my life#{n}"}
    sequence(:citation_year)        {|n| "201#{n}d"}
    journal
    sequence(:series_volume_issue)  {|n| n}
    sequence(:pagination)           {|n| n}
  end

  factory :book_reference do
    author_names                    {[Factory(:author_name)]}
    sequence(:title)                {|n| "Ants are my life#{n}"}
    sequence(:citation_year)        {|n| "201#{n}d"}
    publisher
    pagination                      '22 pp.'
  end

  factory :unknown_reference do
    author_names                    {[Factory(:author_name)]}
    sequence(:title)                {|n| "Ants are my life#{n}"}
    sequence(:citation_year)        {|n| "201#{n}d"}
    citation                        'New York'
  end

  factory :nested_reference do
    author_names                    {[Factory(:author_name)]}
    sequence(:title)                {|n| "Ants are my life#{n}"}
    sequence(:citation_year)        {|n| "201#{n}d"}
    pages_in                        'In: '
    nested_reference                {Factory :book_reference}
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
  factory :taxon do
    protonym
    status  'valid'
  end

  factory :family do
    name     'Formicidae'
    protonym
    status  'valid'
  end

  factory :subfamily do
    sequence(:name) {|n| "Subfamily#{n}"}
    protonym
    status  'valid'
  end

  factory :tribe do
    sequence(:name) {|n| "Tribe#{n}"}
    subfamily
    protonym
    status  'valid'
  end

  factory :genus do
    sequence(:name) {|n| "Genus#{n}"}
    tribe
    subfamily   {|a| a.tribe && a.tribe.subfamily}
    protonym
    status  'valid'
  end

  factory :subgenus do
    sequence(:name) {|n| "Subgenus#{n}"}
    genus
    protonym
    status  'valid'
  end

  factory :species do
    sequence(:name) {|n| "Species#{n}"}
    genus
    protonym
    status  'valid'
  end

  factory :subspecies do
    sequence(:name) {|n| "Subspecies#{n}"}
    species
    protonym
    status  'valid'
  end

  ####################################################
  factory :reference_location do
    reference :factory => :article_reference
    pages '49'
  end

  factory :protonym do
    authorship :factory => :reference_location 
    sequence(:name) {|n| "Protonym#{n}"}
  end

  ####################################################
  factory :text do
    marked_up_text 'Reference'
  end

end

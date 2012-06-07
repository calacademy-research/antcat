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
  factory :name_object do
    name_object_name 'Atta'
  end

  ####################################################
  sequence(:taxon_name) {|n| "Taxon#{n}"}

  factory :taxon do
    ignore {name generate(:taxon_name)}
    name_object {FactoryGirl.create :name_object, name_object_name: name}
    protonym
    status  'valid'
  end

  factory :family do
    ignore {name 'Formicidae'}
    name_object {FactoryGirl.create :name_object, name_object_name: name}
    protonym
    status  'valid'
  end

  factory :subfamily do
    ignore {name generate(:taxon_name)}
    name_object {FactoryGirl.create :name_object, name_object_name: name}
    protonym
    status  'valid'
  end

  factory :tribe do
    ignore {name generate(:taxon_name)}
    name_object {FactoryGirl.create :name_object, name_object_name: name}
    subfamily
    protonym
    status  'valid'
  end

  factory :genus do
    ignore {name generate(:taxon_name)}
    name_object {FactoryGirl.create :name_object, name_object_name: name}
    tribe
    subfamily   {|a| a.tribe && a.tribe.subfamily}
    protonym
    status  'valid'
  end

  factory :subgenus do
    ignore {name generate(:taxon_name)}
    name_object {FactoryGirl.create :name_object, name_object_name: name}
    genus
    protonym
    status  'valid'
  end

  factory :species do
    ignore {name generate(:taxon_name)}
    name_object {FactoryGirl.create :name_object, name_object_name: name}
    genus
    protonym
    status  'valid'
  end

  factory :subspecies do
    ignore {name generate(:taxon_name)}
    name_object {FactoryGirl.create :name_object, name_object_name: name}
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
    authorship :factory => :citation 
    sequence(:name) {|n| "Protonym#{n}"}
  end

  factory :taxonomic_history_item do
    taxt 'Taxonomic history'
  end

end

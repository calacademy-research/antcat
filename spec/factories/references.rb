FactoryGirl.define do
  factory :author

  factory :author_name do
    sequence(:name) { |n| "Fisher#{n}, B.L." }
    author
  end

  factory :reference_author_name do
    association :reference
    association :author_name
  end

  factory :journal do
    sequence(:name) { |n| "Ants#{n}" }
  end

  factory :publisher do
    name 'Wiley'
    place
  end

  factory :place do
    name 'New York'
  end

  factory :reference_document

  factory :reference do
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    author_names { [FactoryGirl.create(:author_name)] }
  end

  factory :article_reference do
    author_names { [FactoryGirl.create(:author_name)] }
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    journal
    sequence(:series_volume_issue) { |n| n }
    sequence(:pagination) { |n| n }
    doi '10.10.1038/nphys1170'
  end

  factory :book_reference do
    author_names { [FactoryGirl.create(:author_name)] }
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    publisher
    pagination '22 pp.'
    doi '10.10.1038/nphys1170'
  end

  factory :unknown_reference do
    author_names { [FactoryGirl.create(:author_name)] }
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    citation 'New York'
  end

  factory :missing_reference do
    title '(missing)'
    citation_year '2009'
    citation 'Latreille, 2009'
  end

  factory :nested_reference do
    author_names { [FactoryGirl.create(:author_name)] }
    sequence(:title) { |n| "Nested ants #{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    pages_in 'In: '
    nesting_reference { FactoryGirl.create :book_reference }
    doi '10.10.1038/nphys1170'
  end
end

def reference_factory attributes = {}
  name = attributes.delete :author_name
  author_name = AuthorName.find_by_name name
  author_name ||= FactoryGirl.create :author_name, name: name
  reference = FactoryGirl.create(:reference, attributes.merge(:author_names => [author_name]))
  reference
end

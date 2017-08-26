FactoryGirl.define do
  factory :reference do
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    author_names { [create(:author_name)] }
  end

  factory :article_reference do
    author_names { [create(:author_name) ] }
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    journal
    sequence(:series_volume_issue) { |n| n }
    sequence(:pagination) { |n| n }
    doi '10.10.1038/nphys1170'
  end

  factory :book_reference do
    author_names { [create(:author_name)] }
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    publisher
    pagination '22 pp.'
    doi '10.10.1038/nphys1170'
  end

  factory :unknown_reference do
    author_names { [create(:author_name)] }
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
    author_names { [create(:author_name)] }
    sequence(:title) { |n| "Nested ants #{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    pages_in 'In: '
    nesting_reference { create :book_reference }
    doi '10.10.1038/nphys1170'
  end
end

# TODO this method allows creating references without a type.
def reference_factory attributes = {}
  name = attributes.delete :author_name
  author_name = AuthorName.find_by(name: name)
  author_name ||= create :author_name, name: name

  fix_type = attributes.delete :fix_type
  if fix_type
    create fix_type, attributes.merge(author_names: [author_name])
  else
    create :reference, attributes.merge(author_names: [author_name])
  end
end

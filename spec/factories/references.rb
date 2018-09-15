FactoryBot.define do
  factory :reference do
    transient do
      author_name {}
    end
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }

    after(:create) do |reference, evaluator|
      if reference.author_names.blank? && evaluator.author_name
        author_name = AuthorName.find_by(name: evaluator.author_name)
        author_name ||= create :author_name, name: evaluator.author_name
        reference.author_names << author_name
      end
    end
  end

  factory :article_reference do
    author_names { [create(:author_name)] }
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

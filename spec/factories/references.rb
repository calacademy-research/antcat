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

    factory :article_reference, class: 'ArticleReference' do
      author_names { [create(:author_name)] }
      journal
      sequence(:series_volume_issue) { |n| n }
      sequence(:pagination) { |n| n }
    end

    factory :book_reference, class: 'BookReference' do
      author_names { [create(:author_name)] }
      publisher
      sequence(:pagination) { |n| "#{n} pp." }
    end

    factory :unknown_reference, class: 'UnknownReference' do
      author_names { [create(:author_name)] }
      citation { 'New York' }
    end

    factory :missing_reference, class: 'MissingReference' do
      title { '(missing)' }
      citation_year { '2009' }
      citation { 'Latreille, 2009' }
    end

    factory :nested_reference, class: 'NestedReference' do
      author_names { [create(:author_name)] }
      pages_in { 'In: ' }
      nesting_reference { create :book_reference }
    end

    trait :with_doi do
      sequence(:doi) { |n| "10.10.1038/nphys117#{n}" }
    end
  end
end

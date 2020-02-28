FactoryBot.define do
  factory :reference do
    transient do
      author_name {}
    end

    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }

    after(:stub) do |reference, evaluator|
      if evaluator.author_names.present?
        reference.author_names = evaluator.author_names
      end
    end

    before(:create) do |reference, evaluator|
      next if reference.is_a?(MissingReference)

      if evaluator.author_names.present?
        reference.author_names = evaluator.author_names
      elsif evaluator.author_name
        author_name = AuthorName.find_by(name: evaluator.author_name)
        author_name ||= create :author_name, name: evaluator.author_name
        reference.author_names << author_name
      else
        reference.author_names = [create(:author_name)]
      end
    end

    factory :article_reference, class: 'ArticleReference' do
      journal
      sequence(:series_volume_issue) { |n| n }
      sequence(:pagination) { |n| n }
    end

    factory :book_reference, class: 'BookReference' do
      publisher
      sequence(:pagination) { |n| "#{n} pp." }
    end

    factory :unknown_reference, class: 'UnknownReference' do
      citation { 'New York' }
    end

    factory :missing_reference, class: 'MissingReference' do
      title { '(missing)' }
      citation_year { '2009' }
      citation { 'Latreille, 2009' }
    end

    factory :nested_reference, class: 'NestedReference' do
      pages_in { 'In: ' }
      nesting_reference { create :book_reference }
    end

    trait :with_doi do
      sequence(:doi) { |n| "10.10.1038/nphys117#{n}" }
    end

    trait :with_document do
      association :document, factory: :reference_document
    end
  end
end

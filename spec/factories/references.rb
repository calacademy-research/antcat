# frozen_string_literal: true

FactoryBot.define do
  factory :reference do
    transient do
      author_string {}
    end

    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }

    after(:stub) do |reference, evaluator|
      if evaluator.author_names.present?
        reference.author_names = evaluator.author_names
      else
        # To make sure we're not adding author names when explicitly passed as an empty array.
        # It's not a super important check, and it's required since `valuator.author_names`
        # is passed as an empty array if nothing is specified.
        raise 'author_names cannot be empty' if evaluator.__override_names__.include?(:author_names)

        def reference.refresh_author_names_cache *args
          # No-op.
        end

        author_names = build_stubbed_list(:author_name, 1)
        author_names.each { |author_name| reference.association(:author_names).add_to_target(author_name) }
      end
    end

    before(:create) do |reference, evaluator|
      next if reference.is_a?(MissingReference)

      if evaluator.author_names.present?
        reference.author_names = evaluator.author_names
      elsif evaluator.author_string
        author_name = AuthorName.find_by(name: evaluator.author_string)
        author_name ||= create :author_name, name: evaluator.author_string
        reference.author_names << author_name
      else
        # See comment above.
        raise 'author_names cannot be empty' if evaluator.__override_names__.include?(:author_names)
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

    factory :unknown_reference, class: 'UnknownReference', aliases: [:any_reference] do
      sequence(:citation) { |n| "New York #{n}" }
    end

    factory :missing_reference, class: 'MissingReference' do
      title { '(missing)' }
      citation_year { '2009' }
      citation { 'Latreille, 2009' }
    end

    factory :nested_reference, class: 'NestedReference' do
      sequence(:pagination) { |n| "pp. #{n} in: " }
      nesting_reference { create :book_reference }
    end

    trait :with_doi do
      sequence(:doi) { |n| "10.10.1038/nphys117#{n}" }
    end

    trait :with_document do
      association :document, factory: :reference_document
    end

    trait :with_notes do
      sequence(:public_notes) { |n| "public_notes #{n}" }
      sequence(:editor_notes) { |n| "editor_notes #{n}" }
      sequence(:taxonomic_notes) { |n| "taxonomic_notes #{n}" }
    end
  end
end

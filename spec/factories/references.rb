# frozen_string_literal: true

FactoryBot.define do
  factory :base_reference, class: 'Reference' do
    transient do
      author_string {}
    end

    sequence(:title) { |n| "Reference#{n}" }
    year { rand(Citation::ICZN_APPLICABILITY_YEAR_RANGE) }

    after(:stub) do |reference, evaluator|
      if evaluator.author_names.present?
        reference.author_names = evaluator.author_names
      else
        # Raise to make sure we're not adding author names by mistake in case an empty array is explicitly passes.
        raise 'author_names cannot be empty' if evaluator.__override_names__.include?(:author_names)

        author_names = build_stubbed_list(:author_name, 1)
        author_names.each { |author_name| reference.association(:author_names).add_to_target(author_name) }
      end

      reference.refresh_author_names_cache
      reference.refresh_key_with_suffixed_year_cache
    end

    before(:create) do |reference, evaluator|
      if evaluator.author_names.present?
        reference.author_names = evaluator.author_names
      elsif evaluator.author_string
        Array.wrap(evaluator.author_string).each do |author_string|
          author_name = AuthorName.find_by(name: author_string)
          author_name ||= create :author_name, name: author_string
          reference.author_names << author_name
        end
      elsif reference.author_names.blank?
        # See comment above.
        raise 'author_names cannot be empty' if evaluator.__override_names__.include?(:author_names)
        reference.author_names = [create(:author_name)]
      end

      reference.refresh_author_names_cache
      reference.refresh_key_with_suffixed_year_cache
    end

    factory :article_reference, class: 'ArticleReference', aliases: [:any_reference] do
      journal
      sequence(:series_volume_issue) { |n| n }
      sequence(:pagination) { |n| "#{n}-#{n + 1}" }
    end

    factory :book_reference, class: 'BookReference' do
      publisher
      sequence(:pagination) { |n| "#{n} pp." }
    end

    factory :nested_reference, class: 'NestedReference' do
      sequence(:pagination) { |n| "Pp. #{n} in:" }
      nesting_reference { create :book_reference }
    end

    trait :with_year_suffix do
      sequence(:year_suffix, ('a'..'z').cycle)
    end

    trait :with_stated_year do
      stated_year { rand(Citation::ICZN_APPLICABILITY_YEAR_RANGE) }
    end

    trait :with_doi do
      sequence(:doi) { |n| "10.10.1038/nphys117#{n}" }
    end

    trait :with_author_name do
      after(:create) do |reference, _evaluator|
        reference.author_names << create(:author_name)
      end
    end

    trait :with_document do
      association :document, factory: [:reference_document, :with_file]
    end

    trait :with_notes do
      sequence(:public_notes) { |n| "public_notes #{n}" }
      sequence(:editor_notes) { |n| "editor_notes #{n}" }
      sequence(:taxonomic_notes) { |n| "taxonomic_notes #{n}" }
    end
  end
end

# frozen_string_literal: true

# TODO: This creates two `ReferenceAuthorName`; one additional for the reference.

FactoryBot.define do
  factory :reference_author_name do
    reference factory: :article_reference
    association :author_name
  end
end

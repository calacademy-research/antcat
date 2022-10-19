# frozen_string_literal: true

# TODO: This creates two `ReferenceAuthorName`s (one additional in the reference factory).

FactoryBot.define do
  factory :reference_author_name do
    reference factory: :any_reference
    association :author_name
  end
end

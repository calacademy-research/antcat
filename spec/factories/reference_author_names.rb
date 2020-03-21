# TODO: This creates two `ReferenceAuthorName`; one additional for the reference.

FactoryBot.define do
  factory :reference_author_name do
    association :reference
    association :author_name
  end
end

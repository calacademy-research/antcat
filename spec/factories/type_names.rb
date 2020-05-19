# frozen_string_literal: true

FactoryBot.define do
  factory :type_name do
    association :taxon, factory: :family
    by_monotypy
  end

  trait :by_monotypy do
    fixation_method { TypeName::BY_MONOTYPY }
  end

  trait :by_original_designation do
    fixation_method { TypeName::BY_ORIGINAL_DESIGNATION }
  end

  trait :by_subsequent_designation_of do
    fixation_method { TypeName::BY_SUBSEQUENT_DESIGNATION_OF }
    association :reference, factory: :any_reference
    sequence(:pages) { |n| n }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :protonym_params, class: Hash do
    with_authorship_attributes

    trait :with_authorship_attributes do
      authorship_attributes do
        {
          pages: generate(:pages),
          reference_id: create(:any_reference).id
        }
      end
    end
  end
end

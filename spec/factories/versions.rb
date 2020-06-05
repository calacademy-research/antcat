# frozen_string_literal: true

FactoryBot.define do
  factory :version, class: 'PaperTrail::Version' do
    item_type { 'Taxon' }
    sequence(:item_id) { |n| n }
    event { 'create' }
    association :whodunnit, factory: :user
  end
end

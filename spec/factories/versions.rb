FactoryBot.define do
  factory :version, class: 'PaperTrail::Version' do
    item_type { 'Taxon' }
    event { 'create' }
    change_id { 0 }
    association :whodunnit, factory: :user
  end
end

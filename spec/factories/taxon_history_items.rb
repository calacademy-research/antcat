FactoryBot.define do
  factory :taxon_history_item do
    taxt { 'history item content' }
    association :taxon, factory: :family
  end
end

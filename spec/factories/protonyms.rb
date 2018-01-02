FactoryBot.define do
  factory :protonym do
    authorship factory: :citation
    association :name, factory: :genus_name
  end
end

# TODO: Add transient attributes for the authorship to avoid `taxon.protonym.authorship.update`.

FactoryBot.define do
  factory :protonym do
    authorship factory: :citation
    genus_group_name

    trait :genus_group_name do
      association :name, factory: :genus_name
    end

    trait :species_group_name do
      association :name, factory: :species_name
    end
  end
end

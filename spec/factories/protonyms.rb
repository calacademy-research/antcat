# TODO: Add transient attributes for the authorship to avoid `taxon.protonym.authorship.update`.

FactoryBot.define do
  factory :protonym do
    authorship factory: :citation
    association :name, factory: :genus_name
  end
end

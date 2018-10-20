FactoryBot.define do
  factory :change do
    change_type "create"
    user
  end
end

def create_taxon_version_and_change user, genus_name = 'default_genus'
  name = create :genus_name, name: genus_name
  taxon = create :genus, name: name
  taxon.taxon_state.review_state = TaxonState::WAITING

  change = create :change, taxon: taxon, change_type: "create", user: user
  create :version, item: taxon, whodunnit: user.id, change: change

  taxon
end

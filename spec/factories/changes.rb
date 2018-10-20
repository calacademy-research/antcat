FactoryBot.define do
  factory :change do
    change_type "create"
    user
  end
end

def create_taxon_version_and_change user
  taxon = create :family
  change = create :change, taxon: taxon, change_type: "create", user: user
  create :version, item: taxon, whodunnit: user.id, change: change
  taxon
end

FactoryGirl.define do
  factory :change do
    change_type "create"
  end

  factory :version, class: PaperTrail::Version do
    item_type 'Taxon'
    event 'create'
    change_id 0
    association :whodunnit, factory: :user
  end
end

def setup_version taxon, whodunnit = nil
  change = create :change, user_changed_taxon_id: taxon.id

  create :version,
    item_id: taxon.id,
    event: 'create',
    item_type: 'Taxon',
    change_id: change.id,
    whodunnit: whodunnit.try(:id)
  change
end

def create_taxon_version_and_change review_state, user = @user, approver = nil, genus_name = 'default_genus'
  name = create :name, name: genus_name
  taxon = create :genus, name: name
  taxon.taxon_state.review_state = review_state

  change = create :change, user_changed_taxon_id: taxon.id, change_type: "create"
  create :version, item_id: taxon.id, whodunnit: user.id, change_id: change.id

  if approver
    change.update! approver: approver, approved_at: Time.now
  end

  taxon
end

FactoryGirl.define do
  factory :taxon_state do
    review_state 'old'
    deleted 0
  end

  factory :synonym do
    association :junior_synonym, factory: :genus
    association :senior_synonym, factory: :genus
  end

  factory :citation do
    reference :factory => :article_reference
    pages '49'
  end

  factory :protonym do
    authorship factory: :citation
    association :name, factory: :genus_name
  end

  factory :taxon_history_item, class: TaxonHistoryItem do
    taxt 'Taxonomic history'
  end

  factory :reference_section do
    association :taxon
    sequence(:position) { |n| n }
    sequence(:references_taxt) { |n| "Reference #{n}" }
  end

  factory :antwiki_valid_taxon

  factory :version, :class => PaperTrail::Version do
    item_type 'Taxon'
    event 'create'
    change_id 0
    association :whodunnit, factory: :user
  end

  factory :transaction do
    association :paper_trail_version, factory: :version
    association :change
  end

  factory :change do
    change_type "create"
  end

  factory :tooltip do
    sequence(:key) { |n| "test.key#{n}" }
    sequence(:text) { |n| "Tooltip text #{n}" }
  end
end

def setup_version taxon_id, whodunnit=nil
  change = FactoryGirl.create :change, user_changed_taxon_id: taxon_id

  FactoryGirl.create :version, item_id: taxon_id, event: 'create', item_type: 'Taxon', change_id: change.id, whodunnit: whodunnit.nil? ? nil : whodunnit.id
  change
end

FactoryGirl.define do
  # TODO default to "waiting" -- nay, "approved" -- because that's the new deal.
  factory :taxon_state do
    review_state 'old'
    deleted 0
  end

  factory :synonym do
    association :junior_synonym, factory: :genus
    association :senior_synonym, factory: :genus
  end

  factory :citation do
    reference factory: :article_reference
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
end

def create_synonym senior, attributes = {}
  junior = create_genus attributes.merge status: 'synonym'
  synonym = Synonym.create! senior_synonym: senior, junior_synonym: junior
  junior
end

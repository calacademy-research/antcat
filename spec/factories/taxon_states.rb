FactoryBot.define do
  # TODO default to "waiting" or "approved".
  factory :taxon_state do
    review_state { TaxonState::OLD }
    deleted { false }
  end
end

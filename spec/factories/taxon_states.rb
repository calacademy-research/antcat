FactoryBot.define do
  # TODO: Default to "waiting" or "approved".
  factory :taxon_state do
    review_state { TaxonState::OLD }
  end
end

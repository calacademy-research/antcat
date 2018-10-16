Given("there is a genus {string} that's waiting for approval") do |name|
  genus = create_genus name
  genus.taxon_state.update_columns review_state: TaxonState::WAITING

  user = User.first
  change = create :change, taxon: genus, user: user
  create :version, item_id: genus.id, whodunnit: user.id, change_id: change.id
end

When("I add the genus {string}") do |name|
  step %(there is a genus "#{name}" that's waiting for approval)
end

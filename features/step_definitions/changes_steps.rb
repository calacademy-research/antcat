When("the changes are approved") do
  TaxonState.update_all review_state: :approved
  Change.update_all approver_id: User.first.id, approved_at: Time.current
end

Given("there is a genus {string} that's waiting for approval") do |name|
  genus = create_genus name
  genus.taxon_state.update_columns review_state: :waiting

  # TODO: Do not use `User.first` or `User.first.id`.
  change = create :change, user_changed_taxon_id: genus.id, user: User.first
  whodunnit = User.first.id
  create :version, item_id: genus.id, whodunnit: whodunnit, change_id: change.id

  # A version is created automatically if PaperTrail is enabled (tag `@papertrail`),
  # but we're having issues creating changes and attaching changes to versions.
  # Use this to attach a change to existing versions:
  # PaperTrail::Version.where(item_id: genus.id, item_type: "Taxon").each do |version|
  #   version.update_columns change_id: change.id, whodunnit: whodunnit
  # end
end

When("I add the genus {string}") do |name|
  step %(there is a genus "#{name}" that's waiting for approval)
end

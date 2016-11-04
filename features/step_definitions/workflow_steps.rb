When(/^the changes are approved$/) do
  TaxonState.update_all review_state: :approved
  Change.update_all approver_id: User.first.id, approved_at: Time.now
end

Given(/^there is a genus "([^"]*)" that's waiting for approval$/) do |name|
  genus = create_genus name
  genus.taxon_state.update_columns review_state: :waiting

  change = create :change, user_changed_taxon_id: genus.id
  whodunnit = User.first.id
  create :version, item_id: genus.id, whodunnit: whodunnit, change_id: change.id

  # A version is created automatically if PaperTrail is enabled (tag `@papertrail`),
  # but we're having issues creating changes and attaching changes to versions.
  # Use this to attach existing versions to a change:
  # PaperTrail::Version.where(item_id: genus.id, item_type: "Taxon").each do |version|
  #   version.update_columns change_id: change.id, whodunnit: whodunnit
  # end
end

When(/^I add the genus "([^"]+)"?$/) do |name|
  step %{there is a genus "#{name}" that's waiting for approval}
end

Then(/^I should see the name "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.name', value
end

Then(/^I should see the genus "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.parent_rank', 'Genus'
  expect(page).to have_css '.parent-test-hook', text: value
end

Then(/^I should see the subfamily "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.parent_rank', 'Subfamily'
  expect(page).to have_css '.parent-test-hook', text: value
end

Then(/^I should see the status "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.status', value
end

Then(/^I should see the incertae sedis status of "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.incertae_sedis', value
end

Then(/^I should see the attribute "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.attributes', value
end

Then(/^I should see the notes "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.notes', value
end

Then(/^I should see the protonym name "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.protonym_name', value
end

Then(/^I should see the protonym attribute "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.protonym_attributes', value
end

Then(/^I should see the authorship reference "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.authorship_reference', value
end

Then(/^I should see the page "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.page', value
end

Then(/^I should see the forms "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.forms', value
end

Then(/^I should see the locality "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.locality', value
end

Then(/^I should see the authorship notes "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.authorship_notes', value
end

Then(/^I should see the type name "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.type_name', value
end

Then(/^I should see the type attribute "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.type_attributes', value
end

Then(/^I should see the type notes "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.type_notes', value
end

Then(/^I should see a history item "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.history_item', value
end

Then(/^I should see a reference section "(.*?)" in the changes$/) do |value|
  should_see_in_changes '.references_taxt', value
end

def should_see_in_changes selector, value
  expect(page).to have_css "#{selector}-test-hook", text: value
end

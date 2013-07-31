# coding: UTF-8
When /^(?:that )?version tracking is (not)?enabled$/ do |is_not|
  PaperTrail.enabled = !is_not
end
When /^the changes are approved$/ do
  Taxon.update_all review_state: :approved
end
Given /^there is a genus "([^"]*)" that's waiting for approval$/ do |name|
  genus = create_genus name, review_state: :waiting
  FactoryGirl.create :change, paper_trail_version: genus.last_version
end

####
def should_see_in_changes selector, value
  page.should have_css selector, text: value
end

Then /^I should see the name "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.name', value
end
Then /^I should see the subfamily "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.parent_rank', 'Subfamily'
  page.should have_css '.parent', text: value
end
Then /^I should see the status "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.status', value
end
Then /^I should see the incertae sedis status of "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.incertae_sedis', value
end
Then /^I should see the attribute "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.attributes', value
end
Then /^I should see the notes "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.notes', value
end
Then /^I should see the protonym name "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.protonym_name', value
end
Then /^I should see the protonym attribute "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.protonym_attributes', value
end
Then /^I should see the authorship reference "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.authorship_reference', value
end
Then /^I should see the page "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.page', value
end
Then /^I should see the forms "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.forms', value
end
Then /^I should see the locality "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.locality', value
end
Then /^I should see the authorship notes "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.authorship_notes', value
end
Then /^I should see the type name "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.type_name', value
end
Then /^I should see the type attribute "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.type_attributes', value
end
Then /^I should see the type notes "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.type_notes', value
end
Then /^I should see a history item "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.history_item', value
end
Then /^I should see a reference section "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.references_taxt', value
end

# coding: UTF-8
When /^version tracking is (not)?enabled$/ do |is_not|
  PaperTrail.enabled = !is_not
end

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
Then /^I should see the note "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.notes', value
end
Then /^I should see the protonym attribute "(.*?)" in the changes$/ do |value|
  should_see_in_changes '.protonym_attributes', value
end

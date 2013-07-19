# coding: UTF-8
When /^version tracking is (not)?enabled$/ do |is_not|
  PaperTrail.enabled = !is_not
end
Then /^I should see the name "(.*?)" in the changes$/ do |subfamily|
  page.should have_css '.name', text: subfamily
end
Then /^I should see the subfamily "(.*?)" in the changes$/ do |subfamily|
  page.should have_css '.parent_rank', text: 'Subfamily'
  page.should have_css '.parent', text: subfamily
end


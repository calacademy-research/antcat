# coding: UTF-8
When /^version tracking is (not)?enabled$/ do |is_not|
  PaperTrail.enabled = !is_not
end

Then /^I should see the name "(.*?)" in the changes$/ do |value|
  page.should have_css '.name', text: value
end


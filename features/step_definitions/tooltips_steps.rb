Given /^(?:these|this) tooltips? (?:also)? ?exists?$/ do |table|
  table.hashes.each do |hash|
    FactoryGirl.create :tooltip, hash
  end
end

# "next to" as in "sibling element".
# Required for hovering selector-based tooltips, because the are always
# inserted after another element.
When(/^I hover the the tooltip next to "([^"]*)"$/) do |text|
  # TODO make easier to understand
  find(:xpath, "//*[contains(., '#{text}')]/following-sibling::" +
    "a[contains(concat(' ', @class, ' '), ' selector-tooltip')]").hover
end

# "within" as in "within the element that matches the text".
# Only for hard-coded tooltips.
When(/^I hover the the tooltip within "([^"]*)"$/) do |text|
  find('*', text: /^#{text}$/).find('img.help_icon').hover
end

Given /^(?:these|this) tooltips? (?:also)? ?exists?$/ do |table|
  table.hashes.each do |hash|
    FactoryGirl.create :tooltip, hash
  end
end

# "next to" as in "sibling element".
# Required for hovering selector-based tooltips, because the are always
# inserted after another element.
When(/^I hover the tooltip next to "([^"]*)"$/) do |text|
  # TODO make easier to understand
  tooltip = first(:xpath, "//*[contains(., '#{text}')]/following::" +
    "*[contains(concat(' ', @class, ' '), ' tooltip')][1]")
  tooltip.hover
end

# "within" as in "within the element that matches the text".
# Only for hard-coded tooltips.
When(/^I hover the tooltip within "([^"]*)"$/) do |text|
  find('*', text: /^#{text}$/).first('img.help_icon').hover
end

Then /^I should (not )?see the tooltip text "([^"]*)"$/ do |should_not, text|
  selector = should_not ? :should_not : :should
  page.send selector, have_css('.ui-tooltip', visible: true, text: text)
end

Then(/^I should not see any tooltips next to "([^"]*)"$/) do |text|
  tooltip = first(:xpath, "//*[contains(., '#{text}')]/following::" +
    "*[contains(concat(' ', @class, ' '), ' tooltip')][1]")
  expect(tooltip).to be nil
end

Then(/^I should not see any tooltips within "([^"]*)"$/) do |text|
  tooltip = find('*', text: /^#{text}$/).first('img.help_icon')
  expect(tooltip).to be nil
end

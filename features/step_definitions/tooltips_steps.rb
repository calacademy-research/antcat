# Note on "next to":
#   I hover the tooltip next to ...
#   I should not see any tooltips next to ...
# Both of these steps can be followed by:
#   ... the text "Text"
#   ... the element containing "Text"
#
# The difference is:
# 'next to the text "Text"' --> "within the element that matches the text"
#    <p>Text<tooltip/></p>
# here <tooltip/> is next to the text "Text".
#
# 'next to the element containing "Text" --> "sibling of the element that contains the text"
#    <p>Text</p><tooltip/>
# here <tooltip/> is next to the element containing "Text"

Given(/^(?:these|this) tooltips? (?:also)? ?exists?$/) do |table|
  table.hashes.each do |hash|
    create :tooltip, hash
  end
end

When(/^I hover the tooltip next to the element containing "([^"]*)"$/) do |text|
  look_next_to_this = first '*', text: /^#{text}$/
  look_next_to_this.find('img[class~=tooltip]').hover
end

When(/^I hover the tooltip next to the text "([^"]*)"$/) do |text|
  find('*', text: /^#{text}$/).first('img.help_icon').hover
end

Then(/^I should (not )?see the tooltip text "([^"]*)"$/) do |should_not, text|
  if should_not
    expect(page).to have_no_css '.ui-tooltip', text: text
  else
    expect(page).to have_css '.ui-tooltip', text: text
  end
end

Then(/^I should not see any tooltips next to the element containing "([^"]*)"$/) do |text|
  look_next_to_this = first '*', text: /^#{text}$/
  expect(look_next_to_this).to have_no_selector '.tooltip'
end

Then(/^I should not see any tooltips next to the text "([^"]*)"$/) do |text|
  tooltip = find('*', text: /^#{text}$/).first 'img.help_icon'
  expect(tooltip).to be nil
end

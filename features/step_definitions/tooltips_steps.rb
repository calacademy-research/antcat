Given("these/this tooltip(s) (also )exist(s)") do |table|
  table.hashes.each do |hash|
    create :tooltip, hash
  end
end

When("I hover the tooltip next to the text {string}") do |text|
  find('*', text: /^#{text}$/, match: :first).first('.tooltip-icon').hover
end

Then(/^I should (not )?see the tooltip text "([^"]*)"$/) do |should_not, text|
  if should_not
    expect(page).to have_no_css '.ui-tooltip', text: text
  else
    expect(page).to have_css '.ui-tooltip', text: text
  end
end

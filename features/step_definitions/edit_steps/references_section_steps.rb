Then(/^the reference section should be "(.*)"$/) do |reference|
  element = first('.reference_sections .reference_section').find 'div.display'
  expect(element.text).to match /#{reference}\.?/
end

When(/^I add a reference section "(.*?)"/) do |text|
  step %{I click the "Add" reference section button}
  step %{I fill in the references field with "#{text}"}
  step %{I save the reference section}
end

When(/^I click the reference section/) do
  first('.reference_sections .reference_section').find('div.display').click
end

When(/^I fill in the references field with "([^"]*)"$/) do |references|
  step %{I fill in "references_taxt" with "#{references}"}
end

When(/^I save the reference section$/) do
  within first('.reference_sections .reference_section') do
    step %{I press "Save"}
  end
end

When(/^I delete the reference section$/) do
  within first('.reference_section') do
    step %{I press "Delete"}
  end
end

Then(/^the reference section should be empty$/) do
  expect(page).to_not have_css '.reference_sections .reference_section'
end

When(/^I cancel the reference section's changes$/) do
  within first('.reference_sections .reference_section') do
    step %{I press "Cancel"}
  end
end

When(/^I click the "Add" reference section button$/) do
  within '.references_section' do
    click_button 'Add'
  end
end

Then(/^I should (not )?see the "Delete" button for the reference/) do |should_not|
  if should_not
    expect(page).to have_no_css 'button.delete'
  else
    expect(page).to have_css 'button.delete'
  end
end

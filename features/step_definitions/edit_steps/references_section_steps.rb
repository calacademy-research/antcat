When(/^I click the add reference section button$/) do
  find('#add-reference-section-button').click
end

When(/^I click on the cancel reference section button$/) do
  find('.references_section a.taxt-editor-cancel-button').click
end

When(/^I click on the edit reference section button$/) do
  find('.references_section a.taxt-editor-edit-button').click
end

When(/^I save the reference section$/) do
  find('.references_section a.taxt-editor-reference-section-save-button').click
end

When(/^I delete the reference section$/) do
  find('.references_section a.taxt-editor-delete-button').click
end

When("I fill in the references field with {string}") do |references|
  step %{I fill in "references_taxt" with "#{references}"}
end

Then(/^the reference section should be empty$/) do
  expect(page).to_not have_css '.reference_sections .reference_section'
end

Then("the reference section should be {string}") do |reference|
  element = first('.references_section').find('.taxt-presenter')
  expect(element.text).to match /#{reference}/
end

When("I add a reference section {string}") do |text|
  step %{I click the add reference section button}
  step %{I fill in the references field with "#{text}"}
  step %{I save the reference section}
end

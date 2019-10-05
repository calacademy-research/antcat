When("I click the add reference section button") do
  find('#add-reference-section-button').click
end

When("I click on the cancel reference section button") do
  find('.references-section a.taxt-editor-cancel-button').click
end

When("I click on the edit reference section button") do
  find('.references-section a.taxt-editor-edit-button').click
end

When("I save the reference section") do
  find('.references-section a.taxt-editor-reference-section-save-button').click
end

When("I delete the reference section") do
  find('.references-section a.taxt-editor-delete-button').click
end

Then("the reference section should be empty") do
  expect(page).to_not have_css '.reference-sections .reference_section'
end

Then("the reference section should be {string}") do |reference|
  element = first('.references-section').find('.taxt-presenter')
  expect(element.text).to match /#{reference}/
end

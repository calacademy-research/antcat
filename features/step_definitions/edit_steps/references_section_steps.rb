Then("the reference section should be empty") do
  expect(page).to_not have_css '.reference-sections .reference_section'
end

Then("the reference section should be {string}") do |reference|
  element = first('.references-section').find('.taxt-presenter')
  expect(element.text).to match /#{reference}/
end

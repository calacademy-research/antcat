# frozen_string_literal: true

Then("the history should be {string}") do |content|
  element = first('.history-items').find('.taxt-presenter')
  expect(element.text).to match /#{content}/
end

Then("the history item field should be {string}") do |content|
  element = first('.history-items').find('textarea')
  expect(element.text).to match /#{content}/
end

Then("the history item field should not be visible") do
  expect(page).to_not have_css '.history-items textarea'
end

Then("the history item field should be visible") do
  expect(page).to have_css '.history-items textarea'
end

Then("the history should be empty") do
  expect(page).to_not have_css '.history-items .history-item'
end

When("I add a history item to {string} that includes a tag for {string}") do |name, tagged_name|
  taxon = Taxon.find_by(name_cache: name)
  tag_taxon = Taxon.find_by(name_cache: tagged_name)

  create :taxon_history_item, taxt: "{tax #{tag_taxon.id}}", taxon: taxon
end

When("I add a history item {string}") do |content|
  step %(I click on the add taxon history item button)
  step %(I fill in "taxt" with "#{content}")
  step %(I press "Save")
end

When("I update the history item to say {string}") do |content|
  steps %(
    And I click on the edit taxon history item button
    And I fill in "taxt" with "#{content}"
    And I click on the save taxon history item button
    And WAIT
  )
end

# frozen_string_literal: true

Given("there is a history item {string}") do |taxt|
  create :history_item, taxt: taxt
end

Given("there is a subfamily protonym {string} with a history item {string}") do |name, taxt|
  protonym = create :protonym, :family_group_name, name: create(:subfamily_name, name: name)
  create :history_item, taxt: taxt, protonym: protonym
end

Given("there is a subfamily protonym {string} with a history item {string} and a markdown link to {string}") do |name, content, key_with_year|
  reference = ReferenceStepsHelpers.find_reference_by_key(key_with_year)
  taxt = "#{content} {ref #{reference.id}}"
  step %(there is a subfamily protonym "#{name}" with a history item "#{taxt}")
end

# Editing.
Then("the history should be {string}") do |content|
  element = first('#history-items').find('.taxt-presenter')
  expect(element.text).to match /#{content}/
end

Then("the history item field should be {string}") do |content|
  element = first('#history-items').find('textarea')
  expect(element.text).to match /#{content}/
end

Then("the history item field should not be visible") do
  expect(page).to_not have_css '#history-items textarea'
end

Then("the history item field should be visible") do
  expect(page).to have_css '#history-items textarea'
end

Then("the history should be empty") do
  expect(page).to_not have_css '#history-items .history-item'
end

When("I add a history item {string}") do |content|
  step %(I click on the add history item button)
  step %(I fill in "taxt" with "#{content}")
  step %(I press "Save")
end

When("I update the most recent history item to say {string}") do |content|
  HistoryItem.last.update!(taxt: content)
end

When("I delete the most recent history item") do
  HistoryItem.last.destroy
end

When(/^I click the add taxon history item button$/) do
  find('#taxt-editor-add-history-item-button').click
end

When(/^I click on the cancel taxon history item button$/) do
  find('.history_items .history_item a.taxt-editor-cancel-button').click
end

When(/^I click on the edit taxon history item button$/) do
  find('.history_items .history_item a.taxt-editor-edit-button').click
end

When(/^I save the taxon history item$/) do
  find('.history_items .history_item a.taxt-editor-history-item-save-button').click
end

When(/^I delete the taxon history item$/) do
  find('.history_items .history_item a.taxt-editor-delete-button').click
end

Then(/^the history should be "(.*)"$/) do |history|
  element = first('.history_items').find('.taxt-presenter')
  expect(element.text).to match /#{history}/
end

Then(/^the history item field should be "(.*)"$/) do |history|
  element = first('.history_items').find('textarea')
  expect(element.text).to match /#{history}/
end

Then(/^the history item field should not be visible$/) do
  expect(page).to_not have_css '.history_items textarea'
end

Then(/^the history item field should be visible$/) do
  expect(page).to have_css '.history_items textarea'
end

Then(/^the history should be empty$/) do
  expect(page).to_not have_css '.history_items .history_item'
end

When(/^I add a history item to "([^"]*)"(?: that includes a tag for "([^"]*)"?$)?/) do |taxon_name, tag_taxon_name|
  taxon = Taxon.find_by_name taxon_name
  taxt =  if tag_taxon_name
            tag_taxon = Taxon.find_by_name tag_taxon_name
            encode_taxon tag_taxon
          else
            'Tag'
          end
  taxon.history_items.create! taxt: taxt
end

When(/^I add a history item "(.*?)"/) do |text|
  step %{I click the add taxon history item button}
  step %{I fill in "taxt" with "#{text}"}
  step %{I press "Save"}
end

When(/^I update the history item to say "([^"]*)"$/) do |text|
  steps %{
    And I click on the edit taxon history item button
    And I fill in "taxt" with "#{text}"
    And I save the taxon history item
    And I wait
  }
end

def encode_taxon taxon
  "{tax #{taxon.id}}"
end

When(/^I press the history item "([^"]*)" button$/) do |button|
  within '.history_items .history_item' do
    step %{I press "#{button}"}
  end
end

When(/^I click the history item$/) do
  find('.history_items .history_item div.display').click
end

Then(/^the history should be "(.*)"$/) do |history|
  element = first('.history_items .history_item_body').find 'div.display'
  expect(element.text).to match /#{history}\.?/
end

Then(/^the history item field should be "(.*)"$/) do |history|
  element = first('.history_items .history_item_body').find 'div.edit textarea'
  expect(element.text).to match /#{history}\.?/
end

Then(/^the history should be empty$/) do
  expect(page).to_not have_css '.history_items .history_item'
end

When(/^I click the "Add History" button$/) do
  within '.history_items_section' do
    click_button 'Add'
  end
end

When(/^I edit the history item to "([^"]*)"$/) do |history|
  step %{I fill in "taxt" with "#{history}"}
end

Then(/^I should (not )?see the "Delete" button for the history item$/) do |should_not|
  selector = should_not ? :should_not : :should
  visible = should_not ? :false : :true
  page.send selector, have_css('button.delete', visible: visible)
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

def encode_taxon taxon
  "{tax #{taxon.id}}"
end

When(/^I add a history item "(.*?)"/) do |text|
  step %{I click the "Add History" button}
  step %{I edit the history item to "#{text}"}
  step %{I save the history item}
end

When(/^I update the history item to say "([^"]*)"$/) do |text|
  steps %{
    And I click the history item
    And I edit the history item to "#{text}"
    And I save the history item
    And I wait
  }
end

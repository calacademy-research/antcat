When(/^I click the first search result$/) do
  find('.search_results .reference_table', match: :first).click
end

Then(/^the authorship field should contain the reference by (\w+)$/) do |author|
  page.find('#authorship_field .display').text.should =~ /#{author}.*/
end

Then(/^the authorship field should contain "([^"]*)"$/) do |contents|
  page.should have_css '#authorship_field .display', text: contents
end

Then(/^the current reference should be "([^"]*)"$/) do |contents|
  page.should have_css '#popup .current .display', text: contents
end

Then(/^the widget results should be "([^"]*)"$/) do |contents|
  page.should have_css '#results', text: contents
end

Then(/^the widget results should be the ID for "([^"]*)"$/) do |key|
  reference = find_reference_by_key key
  step %{the widget results should be "#{reference.id}"}
end

Then(/^the widget results should be the taxt for "Fisher 1995"$/) do
  reference = find_reference_by_key 'Fisher 1995'  # TODO Does this do anything?
  step %{the widget results should be "{Fisher, 1995b v}"}
end

Then(/^I should not see the default reference button$/) do
  page.should_not have_css('button.default_reference')
end

When(/I fill in the reference picker search box with "(.*?)"/) do |search_term|
  within ".antcat_reference_picker" do
    step %{I fill in "q" with "#{search_term}"}
  end
end

When(/I press "Go" by the reference picker search box/) do
  within ".antcat_reference_picker" do
    step 'I press "Go"'
  end
end

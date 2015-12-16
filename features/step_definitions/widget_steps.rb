# coding: UTF-8
Then /^I should (not )?see the reference field edit form$/ do |should_not|
  selector = should_not ? :should_not : :should
  visible = should_not ? :false : :true

  find('.current .reference_item > .edit', visible: visible).send(selector, be_visible)
end

# Reference field/popup
When /^I edit the reference$/ do
  within ".current" do
    step 'I follow "edit"'
  end
end
When /^I save my changes to the current reference$/ do
  within first('.current') do
    step 'I press "Save"'
    step 'I wait for a bit'
  end
end
When /^I set the authors to "([^"]*)"$/ do |names|
  within ".current div.edit" do
    step %{I fill in "reference[author_names_string]" with "#{names}"}
  end
end
When /^I set the title to "([^"]*)"$/ do |title|
  within ".current div.edit" do
    step %{I fill in "reference[title]" with "#{title}"}
  end
end
When /^I add a reference by Brian Fisher$/ do
  click_button "Add"
  within '.current' do
    step %{I fill in "reference[author_names_string]" with "Fisher, B.L."}
    step %{I fill in "reference[title]" with "Between Pacific Tides"}
    step %{I fill in "reference_journal_name" with "Ants"}
    step %{I fill in "reference[series_volume_issue]" with "2"}
    step %{I fill in "article_pagination" with "1"}
    step %{I fill in "reference[citation_year]" with "1992"}
    step %{I press "Save"}
    step %{I wait for a bit}
  end
end

# Search
When /In the search box, I press "Go"/ do
  step 'I press "Go" within ".expansion"'
end

When /^I search for the authors? "([^"]*)"$/ do |authors|
  step %{I fill in the search box with "author:'#{authors}'"}
  sleep 1
  step %{In the search box, I press "Go"}
  sleep 4
end

# Reference field
And /^I click the reference field$/ do
  sleep 2
  step %{I click ".display_button"}
  sleep 2
end

# Reference popup
Then /I should (not )?see the reference popup/ do |should_not|
  visible = should_not ? :false : :true
  selector = should_not ? :should_not : :should
  find('.antcat_reference_popup', visible: visible).send(selector, be_visible)
end

# Name field
When /I click the allow_blank name field/ do
  step %{I click "#test_allow_blank_name_field .display_button"}
end
When /I click the new_or_homonym field/ do
  step %{I click "#test_new_or_homonym_name_field .display_button"}
end
When /the default_name_string field should contain "([^"]*)"/ do |name|
  find('#test_default_name_string_name_field #name_string').value.should == name
end
When /I click the default_name_string field/ do
  step %{I click "#test_default_name_string_name_field .display_button"}
end
When /I click the test name field/ do
  step %{I click "#test_name_field .display_button"}
end

# Name popup
Then /^I should (not )?see the name popup edit interface$/ do |should_not|
  selector = should_not ? :should_not : :should
  visible = should_not ? :false : :true
  find('#popup .controls', visible: visible).send(selector, be_visible)
end
Then /^I should (not )?see the name popup$/ do |should_not|
  selector = should_not ? :should_not : :should
  visible = should_not ? :false : :true
  find('.antcat_name_popup', visible: visible).send(selector, be_visible)
end

# Results section
Then /in the results section I should see the editable taxt for the name "([^"]*)"/ do |text|
  within "#results" do
    step %{I should see "#{Taxt.to_editable_name(Name.find_by_name(text))}"}
  end
end
Then /in the results section I should see the id for "([^"]*)"/ do |text|
  within "#results" do
    step %{I should see "#{Name.find_by_name(text).id}"}
  end
end
Then /in the results section I should see the id for the name "([^"]*)"/ do |text|
  within "#results" do
    step %{I should see "#{Name.find_by_name(text).id}"}
  end
end
Then /in the results section I should see the editable taxt for "([^"]*)"/ do |text|
  within "#results" do
    step %{I should see "#{Taxt.to_editable_taxon(Taxon.find_by_name(text))}"}
  end
end

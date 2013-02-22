# coding: UTF-8

When /^I click the edit icon$/ do
  step 'I follow "edit"'
end

# Reference field
Then /I should (not )?see the reference field/ do |should_not|
  selector = should_not ? :should_not : :should
  find('.antcat_reference_field').send(selector, be_visible)
end

When /^I edit the reference$/ do
  within ".current" do
    step 'I follow "edit"'
  end
end

When /^I add a reference$/ do
  within ".expansion" do
    step 'I follow "Add"'
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
  step 'I press "Add"'
  within '.current' do
    step %{I fill in "reference[author_names_string]" with "Fisher, B.L."}
    step %{I fill in "reference[title]" with "Between Pacific Tides"}
    step %{I fill in "reference_journal_name" with "Ants"}
    step %{I fill in "reference[series_volume_issue]" with "2"}
    step %{I fill in "article_pagination" with "1"}
    step %{I fill in "reference[citation_year]" with "1992"}
    step %{I save my changes}
  end
end

When /In the search box, I press "Go"/ do
  step 'I press "Go" within ".expansion"'
end

When /^I search for "([^"]*)"$/ do |search_term|
  # this is to make the selectmenu work
  within '.expansion' do
    step %{I follow "Search for"}
    step %{I follow "Search for"}
    step "I fill in the search box with \"#{search_term}\""
    step %{In the search box, I press "Go"}
  end
end

When /^I search for the authors? "([^"]*)"$/ do |authors|
  within '.expansion' do
    step %{I follow "Search for author(s)"}
  end
  step %{I fill in the search box with "#{authors}"}
  step %{In the search box, I press "Go"}
end

# Reference popup
Then /I should (not )?see the reference popup/ do |should_not|
  selector = should_not ? :should_not : :should
  find('.antcat_reference_popup').send(selector, be_visible)
end

# Name field
Then /I should see the first name in the name field/  do
  step %{I should see "#{Name.first.name}" in the name field}
end

And /^I click the name field$/ do
  step %{I click ".display_button"}
end

# Name picker
Then /in the name picker display I should see "([^"]*)"/ do |text|
  within "#picker .display" do
    step %{I should see "#{text}"}
  end
end

Then /^I should (not )?see the name picker edit interface$/ do |should_not|
  selector = should_not ? :should_not : :should
  find('#picker .edit').send(selector, be_visible)
end

Then /^I should (not )?see the name picker$/ do |should_not|
  selector = should_not ? :should_not : :should
  find('.antcat_name_picker').send(selector, be_visible)
end

# Name popup
Then /in the name popup display I should see the first name/ do
  within "#popup .display" do
    step %{I should see "#{Name.first.name}"}
  end
end

Then /in the name popup display I should see "([^"]*)"/ do |text|
  within "#popup .display" do
    step %{I should see "#{text}"}
  end
end

Then /^I should (not )?see the name popup edit interface$/ do |should_not|
  selector = should_not ? :should_not : :should
  find('#popup .buttons').send(selector, be_visible)
end

Then /^I should (not )?see the name popup$/ do |should_not|
  selector = should_not ? :should_not : :should
  find('.antcat_name_popup').send(selector, be_visible)
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

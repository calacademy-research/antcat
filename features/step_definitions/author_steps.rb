# coding: UTF-8
Given /^I click "edit" in the first row$/ do
  find('#authors a.edit_link:first').click
end

When /^I click the "Add Author Name" button$/ do
  within '.author_names_section' do
    click_button 'Add'
  end
end

When /^I edit the author name to "([^"]*)"$/ do |name|
  step %{I fill in "author_name" with "#{name}"}
end

When /^I save the author name$/ do
  within '.author_name_sections .author_name_section:first' do
    step %{I press "Save"}
  end
end

Then /^the author_name should be "(.*)"$/ do |author_name|
  page.find('.author_names .author_name_body:first div.display').text.should =~ /#{author_name}\.?/
end

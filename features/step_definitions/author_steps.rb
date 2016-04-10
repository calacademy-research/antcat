Given /^I click "edit" in the first row$/ do
  first('#content table a').click
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
  page.find('.author_names button.submit').click()
end

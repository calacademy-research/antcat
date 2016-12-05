When(/^I edit the author name to "([^"]*)"$/) do |name|
  step %{I fill in "author_name" with "#{name}"}
end

When(/^I save the author name$/) do
  find('.author_names button.submit').click
end

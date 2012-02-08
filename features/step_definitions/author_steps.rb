# coding: UTF-8

Given /^the following names exist for an(?:other)? author$/ do |table|
  @author = Factory :author
  table.hashes.each do |hash|
    @author.names.create! name: hash[:name]
  end
end

When /I fill in "([^"]+)" in (the (?:(?:first|last|another) )?author panel) with "(.*?)"/ do |field, parent, search_term|
  with_scope parent do
    step %{I fill in "#{field}" with "#{search_term}"}
  end
end

When /^I search for "([^"]*)" in the author panel$/ do |term|
  step %{I fill in "Choose author" in the author panel with "#{term}"}
  step %{And I press "Go" in the author panel}
end

When /^I search for "([^"]*)" in another author panel$/ do |term|
  step %{I fill in "Choose another author" in the last author panel with "#{term}"}
  step %{I press "Go" in the last author panel}
end

When /^I close the first author panel$/ do
  step %{I follow "close" in the first author panel}
end

When /^I merge the authors$/ do
  step %{I will confirm on the next step}
  step %{I press "Merge these authors"}
end

Then /^I should not be able to merge the authors$/ do
  step %{I should not see "Click this button"}
end

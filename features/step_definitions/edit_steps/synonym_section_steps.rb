When(/^I save the senior synonym$/) do
  step %{I press the senior synonym item "Save" button}
end

When(/^I press the senior synonym item "([^"]*)" button$/) do |button|
  within '.senior_synonyms_section' do
    step %{I press "#{button}"}
  end
end

When(/^I press the (?:junior )?synonym item "([^"]*)" button$/) do |button|
  within '.junior_synonyms_section' do
    step %{I press "#{button}"}
  end
end

When(/^I click "(.*?)" beside the first junior synonym$/) do |button|
  within '.junior_synonyms_section .synonym_row' do
    step %{I press "#{button}"}
  end
end

When(/^I click "(.*?)" beside the first senior synonym$/) do |button|
  within '.senior_synonyms_section .synonym_row' do
    step %{I press "#{button}"}
  end
end

When(/^I fill in the junior synonym name with "([^"]*)"$/) do |name|
  within '.junior_synonyms_section .edit' do
    step %{I fill in "name" with "#{name}"}
  end
end

When(/^I fill in the senior synonym name with "([^"]*)"$/) do |name|
  within '.senior_synonyms_section .edit' do
    step %{I fill in "name" with "#{name}"}
  end
end

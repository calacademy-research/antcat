def already_opened_select2(value, from:)
  element_id = from

  find('.select2-search__field').set value
  find(".select2-results__option", text: /#{value}/).click
end

When("I save the senior synonym") do
  step %{I press the senior synonym item "Save" button}
end

When("I save the synonym") do
  step %{I press the synonym item "Save" button}
end

When("I press the senior synonym item {string} button") do |button|
  within '.senior_synonyms_section' do
    step %{I press "#{button}"}
  end
end

When(/^I press the (?:junior )?synonym item "([^"]*)" button$/) do |button|
  within '.junior_synonyms_section' do
    step %{I press "#{button}"}
  end
end

When("I click {string} beside the first junior synonym") do |button|
  within '.junior_synonyms_section .synonym_row' do
    step %{I press "#{button}"}
  end
end

When("I click {string} beside the first senior synonym") do |button|
  within '.senior_synonyms_section .synonym_row' do
    step %{I press "#{button}"}
  end
end

When("I fill in the junior synonym name with {string}") do |name|
  already_opened_select2 name, from: 'synonym_taxon_id'
end

When("I fill in the senior synonym name with {string}") do |name|
  already_opened_select2 name, from: 'synonym_taxon_id'
end

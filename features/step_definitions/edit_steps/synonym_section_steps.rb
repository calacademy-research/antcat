def already_opened_select2(value, from:) # rubocop:disable Lint/UnusedMethodArgument
  # TODO figure out why this isn't used or remove.
  # element_id = from

  find('.select2-search__field').set value
  find(".select2-results__option", text: /#{value}/).click
end

When("I save the senior synonym") do
  within '#senior-synonyms-section-test-hook' do
    step %(I press "Save")
  end
end

When("I save the synonym") do
  within '#junior-synonyms-section-test-hook' do
    step %(I press "Save")
  end
end

When("I click {string} beside the first junior synonym") do |button|
  within '#junior-synonyms-section-test-hook' do
    step %(I press "#{button}")
  end
end

When("I click {string} beside the first senior synonym") do |button|
  within '#senior-synonyms-section-test-hook' do
    step %(I press "#{button}")
  end
end

When("I fill in the junior synonym name with {string}") do |name|
  already_opened_select2 name, from: 'synonym_taxon_id'
end

When("I fill in the senior synonym name with {string}") do |name|
  already_opened_select2 name, from: 'synonym_taxon_id'
end

# Without JavaScript, `I press "Save"` raises `Capybara::Ambiguous`.
When("I save the taxon form") do
  find("#save-taxon-form").click
end

When("I pick {string} from the {string} taxon selector") do |name, taxon_selector_id|
  select2 name, from: taxon_selector_id
end

# fields section
### name field
When("I set the name to {string}") do |name|
  step %(I fill in "taxon_name_string" with "#{name}")
end

#### current valid taxon field
Then("the current valid taxon name should be {string}") do |name|
  taxon = Taxon.find_by(name_cache: name)
  element = find '#taxon_current_valid_taxon_id'
  expect(element.value).to eq taxon.id.to_s
end

When("I set the current valid taxon name to {string}") do |name|
  select2 name, from: 'taxon_current_valid_taxon_id'
end

# status
Then("the homonym replaced by name should be {string}") do |name|
  expected_value = if name == '(none)'
                     ''
                   else
                     Taxon.find_by(name_cache: name).id.to_s
                   end
  expect(find('#taxon_homonym_replaced_by_id').value).to eq expected_value
end

When("I set the homonym replaced by name to {string}") do |name|
  select2 name, from: 'taxon_homonym_replaced_by_id'
end

### authorship
When(/^I set the authorship to the first search results of "([^"]*)"$/) do |name|
  select2 name, from: 'taxon_protonym_attributes_authorship_attributes_reference_id'
end

Then(/^the authorship should contain the reference "([^"]*)"$/) do |keey|
  reference_id = find_reference_by_keey(keey).id
  selector = '#taxon_protonym_attributes_authorship_attributes_reference_id'
  expect(find(selector).value).to eq reference_id.to_s
end

### protonym name field
When("I set the protonym name to {string}") do |name|
  step %(I fill in "protonym_name_string" with "#{name}")
end

# type name field
When("I set the type name to {string}") do |name|
  select2 name, from: 'taxon_type_taxon_id'
end

Then("the type name field should contain {string}") do |name|
  taxon = Taxon.find_by(name_cache: name)
  element = find '#taxon_type_taxon_id'
  expect(element.value).to eq taxon.id.to_s
end

# convert species to subspecies
Then("the new species field should contain {string}") do |name|
  taxon = Taxon.find_by(name_cache: name)
  element = find '#new_species_id'
  expect(element.value).to eq taxon.id.to_s
end

When("I set the new species field to {string}") do |name|
  select2 name, from: 'new_species_id'
end

# Misc
Then("{string} should be of the rank of {string}") do |name, rank|
  taxon = Taxon.find_by(name_cache: name)
  expect(taxon.rank).to eq rank
end

When("I set {string} to {string} [select-two]") do |id, name|
  select2 name, from: id
end

Then("the {string} of {string} should be {string}") do |association, taxon_name, other_taxon_name|
  taxon = Taxon.find_by(name_cache: taxon_name)
  other_taxon = Taxon.find_by(name_cache: other_taxon_name)

  expect(taxon.public_send(association.to_sym)).to eq other_taxon
end

When("I set the new parent field to {string}") do |name|
  select2 name, from: 'new_parent_id'
end

When("I set the obsolete genus field to {string}") do |name|
  select2 name, from: 'obsolete_genus_id'
end

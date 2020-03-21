When("I pick {string} from the {string} taxon selector") do |name, taxon_selector_id|
  select2 name, from: taxon_selector_id
end

# Name.
When("I set the name to {string}") do |name|
  step %(I fill in "taxon_name_string" with "#{name}")
end

# Current valid taxon.
When("I set the current valid taxon name to {string}") do |name|
  select2 name, from: 'taxon_current_valid_taxon_id'
end

# Homonym replaced by.
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

# Authorship.
When(/^I set the authorship to the first search results of "([^"]*)"$/) do |name|
  select2 name, from: 'taxon_protonym_attributes_authorship_attributes_reference_id'
end

Then(/^the authorship should contain the reference "([^"]*)"$/) do |keey|
  reference_id = find_reference_by_keey(keey).id
  selector = '#taxon_protonym_attributes_authorship_attributes_reference_id'
  expect(find(selector).value).to eq reference_id.to_s
end

# Protonym name.
When("I set the protonym name to {string}") do |name|
  step %(I fill in "protonym_name_string" with "#{name}")
end

# Type taxon.
When("I set the type name to {string}") do |name|
  select2 name, from: 'taxon_type_taxon_id'
end

# Convert species to subspecies.
When("I set the new species field to {string}") do |name|
  select2 name, from: 'new_species_id'
end

# Force-change parent.
When("I set the new parent field to {string}") do |name|
  select2 name, from: 'new_parent_id'
end

# Create missing obsolete combination.
When("I set the obsolete genus field to {string}") do |name|
  select2 name, from: 'obsolete_genus_id'
end

# Misc.
Then("{string} should be of the rank of {string}") do |name, rank|
  taxon = Taxon.find_by(name_cache: name)
  expect(taxon.rank).to eq rank
end

Then("the {string} of {string} should be {string}") do |association, taxon_name, other_taxon_name|
  taxon = Taxon.find_by(name_cache: taxon_name)
  other_taxon = Taxon.find_by(name_cache: other_taxon_name)

  expect(taxon.public_send(association.to_sym)).to eq other_taxon
end

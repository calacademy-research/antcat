# frozen_string_literal: true

# Name.
When("I set the name to {string}") do |name|
  step %(I fill in "taxon_name_string" with "#{name}")
end

# Protonym name.
When("I set the protonym name to {string}") do |name|
  step %(I fill in "protonym_name_string" with "#{name}")
end

# Misc.
Then("{string} should be of the rank of {string}") do |name, rank|
  taxon = Taxon.find_by!(name_cache: name)
  expect(taxon.rank).to eq rank
end

Then("the {string} of {string} should be {string}") do |association, taxon_name, other_taxon_name|
  taxon = Taxon.find_by!(name_cache: taxon_name)
  other_taxon = Taxon.find_by!(name_cache: other_taxon_name)

  expect(taxon.public_send(association)).to eq other_taxon
end

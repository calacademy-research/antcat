Given /^there is a(n invalid)? species described in (\d+)(?: by "([^"]+)")?$/ do |invalid, year, author|
  reference = create :article_reference, citation_year: year
  if author
    bolton = create :author
    author_name = create :author_name, name: author, author: bolton
    reference.author_names = [author_name]
  end

  taxon = create_species
  create :taxon_state, taxon_id: taxon.id

  taxon.update_attributes! status: 'synonym' if invalid
  taxon.protonym.authorship.update_attributes! reference: reference
end

Given /^there is an original combination of "([^"]+)" described by "([^"]+)" which was moved to "([^"]+)"$/ do |original_combination, author, current_valid_taxon|
  reference = create :article_reference
  bolton = create :author
  author_name = create :author_name, name: author, author: bolton
  reference.author_names = [author_name]
  betta_major = create_species 'Betta major'
  create :taxon_state, taxon_id: betta_major.id
  atta_major = create_species 'Atta major', status: 'original combination', current_valid_taxon: atta_major
  create :taxon_state, taxon_id: atta_major.id
  atta_major.protonym.authorship.update_attributes! reference: reference
  atta_major.update_attributes current_valid_taxon: betta_major
  betta_major.protonym.authorship.update_attributes! reference: reference
end

Given /^there is a subfamily described in (\d+)/ do |year|
  reference = create :article_reference, citation_year: year
  taxon = create :subfamily

  create :taxon_state, taxon_id: taxon.id
  taxon.protonym.authorship.update_attributes! reference: reference
end

Given /^there is a genus located in "([^"]+)"$/ do |locality|
  protonym = create :protonym, locality: locality
  genus = create :genus, protonym: protonym
  create :taxon_state, taxon_id: genus.id
end

Given /^there is a species located in "([^"]+)"$/ do |locality|
  protonym = create :protonym, locality: locality
  species = create :species, protonym: protonym
  create :taxon_state, taxon_id: species.id
end

Given /^there is a species with verbatim type locality "([^"]+)"$/ do |locality|
  species = create :species, verbatim_type_locality: locality
  create :taxon_state, taxon_id: species.id
end

Given /^there is a species with type specimen repository "([^"]+)"$/ do |repository|
  species = create :species, type_specimen_repository: repository
  create :taxon_state, taxon_id: species.id
end

Given /^there is a species with type specimen code "([^"]+)"$/ do |code|
  species = create :species, type_specimen_code: code
  create :taxon_state, taxon_id: species.id
end

Given /^there is a species with biogeographic region "([^"]+)"$/ do |biogeographic_region|
  species = create :species, biogeographic_region: biogeographic_region
  create :taxon_state, taxon_id: species.id
end

Given /^there is a species with forms "([^"]+)"$/ do |forms|
  citation = create :citation, forms: forms
  protonym = create :protonym, authorship: citation
  species = create :species, protonym: protonym
  create :taxon_state, taxon_id: species.id
end

Then /^I should see the species described in (\d+)$/ do |year|
  step %{I should see "#{year}"}
end

And /^I select "([^"]+)" from the rank selector$/ do |value|
  step %{I select "#{value}" from "rank"}
end

And /^I select "([^"]+)" from the biogeographic region selector$/ do |value|
  step %{I select "#{value}" from "biogeographic_region"}
end

When /^I check valid only in the advanced search form$/ do
  find(:css, "#advanced_search input[type='checkbox']").set true
end

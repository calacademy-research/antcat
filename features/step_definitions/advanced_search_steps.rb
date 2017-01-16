Given(/^there is a(n invalid)? species described in (\d+)(?: by "([^"]+)")?$/) do |invalid, year, author|
  reference = create :article_reference, citation_year: year
  if author
    bolton = create :author
    author_name = create :author_name, name: author, author: bolton
    reference.author_names = [author_name]
  end

  taxon = create_species
  taxon.update! status: 'synonym' if invalid
  taxon.protonym.authorship.update! reference: reference
end

Given(/^there is an original combination of "([^"]+)" described by "([^"]+)" which was moved to "([^"]+)"$/) do |original_combination, author, current_valid_taxon|
  reference = create :article_reference
  bolton = create :author
  author_name = create :author_name, name: author, author: bolton
  reference.author_names = [author_name]

  betta_major = create_species 'Betta major'
  atta_major = create_species 'Atta major', status: 'original combination', current_valid_taxon: atta_major
  atta_major.protonym.authorship.update! reference: reference
  atta_major.update current_valid_taxon: betta_major
  betta_major.protonym.authorship.update! reference: reference
end

Given(/^there is a subfamily described in (\d+)/) do |year|
  taxon = create :subfamily
  reference = create :article_reference, citation_year: year
  taxon.protonym.authorship.update! reference: reference
end

Given(/^there is a genus located in "([^"]+)"$/) do |locality|
  protonym = create :protonym, locality: locality
  create :genus, protonym: protonym
end

Given(/^there is a species located in "([^"]+)"$/) do |locality|
  protonym = create :protonym, locality: locality
  create :species, protonym: protonym
end

Given(/^there is a species with verbatim type locality "([^"]+)"$/) do |locality|
  create :species, verbatim_type_locality: locality
end

Given(/^there is a species with type specimen repository "([^"]+)"$/) do |repository|
  create :species, type_specimen_repository: repository
end

Given(/^there is a species with type specimen code "([^"]+)"$/) do |code|
  create :species, type_specimen_code: code
end

Given(/^there is a species with biogeographic region "([^"]+)"$/) do |biogeographic_region|
  create :species, biogeographic_region: biogeographic_region
end

Given(/^there is a species with forms "([^"]+)"$/) do |forms|
  citation = create :citation, forms: forms
  protonym = create :protonym, authorship: citation
  create :species, protonym: protonym
end

Then(/^I should see the species described in (\d+)$/) do |year|
  step %{I should see "#{year}"}
end

When(/^I select "([^"]+)" from the rank selector$/) do |value|
  step %{I select "#{value}" from "rank"}
end

When(/^I select "([^"]+)" from the biogeographic region selector$/) do |value|
  step %{I select "#{value}" from "biogeographic_region"}
end

When(/^I check valid only in the advanced search form$/) do
  find(:css, "#advanced_search input[type='checkbox']").set true
end

Then(/^I should get a download with the filename "([^\"]*)"$/) do |filename|
  content_disposition = page.response_headers['Content-Disposition']
  expect(content_disposition).to include "filename=\"#{filename}\""
end

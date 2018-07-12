Given(/^there is a(n invalid)? species described in (\d+)(?: by "([^"]+)")?$/) do |invalid, year, author|
  reference = create :article_reference, citation_year: year
  if author
    bolton = create :author
    author_name = create :author_name, name: author, author: bolton
    reference.author_names = [author_name]
  end

  taxon = create_species
  taxon.update! status: Status::SYNONYM if invalid
  taxon.protonym.authorship.update! reference: reference
end

Given("there is an original combination of {string} described by {string} which was moved to {string}") do |original_combination, author, current_valid_taxon|
  reference = create :article_reference
  bolton = create :author
  author_name = create :author_name, name: author, author: bolton
  reference.author_names = [author_name]

  betta_major = create_species 'Betta major'
  atta_major = create_species 'Atta major', status: Status::ORIGINAL_COMBINATION, current_valid_taxon: atta_major
  atta_major.protonym.authorship.update! reference: reference
  atta_major.update current_valid_taxon: betta_major
  betta_major.protonym.authorship.update! reference: reference
end

Given("there is a subfamily described in {int}") do |year|
  taxon = create :subfamily
  reference = create :article_reference, citation_year: year
  taxon.protonym.authorship.update! reference: reference
end

Given("there is a genus located in {string}") do |locality|
  protonym = create :protonym, locality: locality
  create :genus, protonym: protonym
end

Given("there is a species located in {string}") do |locality|
  protonym = create :protonym, locality: locality
  create :species, protonym: protonym
end

Given("there is a species with biogeographic region {string}") do |biogeographic_region|
  create :species, biogeographic_region: biogeographic_region
end

Given("there is a species with forms {string}") do |forms|
  citation = create :citation, forms: forms
  protonym = create :protonym, authorship: citation
  create :species, protonym: protonym
end

Then("I should see the species described in {int}") do |year|
  step %{I should see "#{year}"}
end

When("I select {string} from the rank selector") do |value|
  step %{I select "#{value}" from "rank"}
end

When("I select {string} from the biogeographic region selector") do |value|
  step %{I select "#{value}" from "biogeographic_region"}
end

When(/^I check valid only in the advanced search form$/) do
  find(:css, "#advanced_search input[type='checkbox']").set true
end

Then("I should get a download with the filename {string}") do |filename|
  content_disposition = page.response_headers['Content-Disposition']
  expect(content_disposition).to include "filename=\"#{filename}\""
end

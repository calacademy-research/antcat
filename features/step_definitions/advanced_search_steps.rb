# frozen_string_literal: true

Given("there is a species described in {int}") do |year|
  reference = create :any_reference, year: year
  taxon = create :species
  taxon.protonym.authorship.update!(reference: reference)
end

Given("there is a species described by Bolton") do
  reference = create :any_reference, author_string: 'Bolton'
  taxon = create :species
  taxon.protonym.authorship.update!(reference: reference)
end

Given("there is an invalid family") do
  create :family, :excluded_from_formicidae
end

Given("there is a species with locality {string}") do |locality|
  protonym = create :protonym, :species_group, locality: locality
  create :species, protonym: protonym
end

Given("there is a species with biogeographic region {string}") do |biogeographic_region|
  protonym = create :protonym, :species_group, biogeographic_region: biogeographic_region
  create :species, protonym: protonym
end

Given("there is a species with forms {string}") do |forms|
  protonym = create :protonym, :species_group, forms: forms
  create :species, protonym: protonym
end

Then("I should get a download with the filename {string} and today's date") do |filename|
  date = Time.current.strftime("%Y-%m-%d")
  content_disposition = page.response_headers['Content-Disposition']
  expect(content_disposition).to include %(filename="#{filename}#{date}__)
end

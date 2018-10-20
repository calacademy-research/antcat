Given("there is a species described in {int}") do |year|
  reference = create :article_reference, citation_year: year
  taxon = create :species
  taxon.protonym.authorship.update! reference: reference
end

Given("there is a species described by Bolton") do
  reference = create :article_reference, author_names: [create(:author_name, name: 'Bolton')]
  taxon = create :species
  taxon.protonym.authorship.update! reference: reference
end

Given("there is an invalid species described in {int}") do |year|
  reference = create :article_reference, citation_year: year
  taxon = create :species, :synonym
  taxon.protonym.authorship.update! reference: reference
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

When("I check valid only in the advanced search form") do
  find(:css, "#advanced_search input[type='checkbox']").set true
end

Then("I should get a download with the filename {string}") do |filename|
  content_disposition = page.response_headers['Content-Disposition']
  expect(content_disposition).to include %(filename="#{filename}")
end

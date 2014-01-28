# coding: UTF-8
Given /^there is a(n invalid)? species described in (\d+)(?: by "([^"]+)")?$/ do |invalid, year, author|
  reference = FactoryGirl.create :article_reference, citation_year: year
  if author
    bolton = FactoryGirl.create :author
    author_name = FactoryGirl.create :author_name, name: author, author: bolton
    reference.author_names = [author_name]
  end
  taxon = FactoryGirl.create :species
  taxon.update_attributes! status: 'synonym' if invalid
  taxon.protonym.authorship.update_attributes! reference: reference
end

Given /^there is an original combination of "([^"]+)" described by "([^"]+)" which was moved to "([^"]+)"$/ do |original_combination, author, current_valid_taxon|
  reference = FactoryGirl.create :article_reference
  bolton = FactoryGirl.create :author
  author_name = FactoryGirl.create :author_name, name: author, author: bolton
  reference.author_names = [author_name]
  betta_major = create_species 'Betta major'
  atta_major = create_species 'Atta major', status: 'original combination', current_valid_taxon: atta_major
  atta_major.protonym.authorship.update_attributes! reference: reference
  atta_major.update_attributes current_valid_taxon: betta_major
  betta_major.protonym.authorship.update_attributes! reference: reference
end

Given /^there were (\d+) species described in (\d+)$/ do |count, year|
  Species.delete_all
  reference = FactoryGirl.create :article_reference, citation_year: year
  count.to_i.times do |i|
    taxon = FactoryGirl.create :species
    taxon.protonym.authorship.update_attributes! reference: reference
  end
end

Given /^there is a subfamily described in (\d+)/ do |year|
  reference = FactoryGirl.create :article_reference, citation_year: year
  taxon = FactoryGirl.create :subfamily
  taxon.protonym.authorship.update_attributes! reference: reference
end

Given /^there is a genus located in "([^"]+)"$/ do |locality|
  protonym = FactoryGirl.create :protonym, locality: locality
  FactoryGirl.create :genus, protonym: protonym
end
Given /^there is a species located in "([^"]+)"$/ do |locality|
  protonym = FactoryGirl.create :protonym, locality: locality
  FactoryGirl.create :species, protonym: protonym
end
Given /^there is a species with verbatim type locality "([^"]+)"$/ do |locality|
  FactoryGirl.create :species, verbatim_type_locality: locality
end
Given /^there is a species with type specimen repository "([^"]+)"$/ do |repository|
  FactoryGirl.create :species, type_specimen_repository: repository
end
Given /^there is a species with type specimen code "([^"]+)"$/ do |code|
  FactoryGirl.create :species, type_specimen_code: code
end
Given /^there is a species with biogeographic region "([^"]+)"$/ do |biogeographic_region|
  FactoryGirl.create :species, biogeographic_region: biogeographic_region
end
Then /^I should see the genus located in "([^"]+)"$/ do |locality|
  step %{I should see "#{locality}"}
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

Given /^I search for and find a result$/ do
  step %{there is a species described in 2010 by "Bolton, B."}
  step %{I fill in "author_name" with "Bolton, B."}
  step %{I press "Go" in the search section}
end

# coding: UTF-8

Given /^there is a(n invalid)? species described in (\d+)$/ do |invalid, year|
  reference = FactoryGirl.create :article_reference, citation_year: year
  taxon = FactoryGirl.create :species
  taxon.update_attributes! status: 'synonym' if invalid
  taxon.protonym.authorship.update_attributes! reference: reference
end

Given /^AntCat shows (\d+) species per page$/ do |count|
  WillPaginate.per_page = count
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

Then /^I should see the species described in (\d+)$/ do |year|
  step %{I should see "#{year}"}
end

And /^I select "([^"]+)" from the rank selector$/ do |value|
  step %{I select "#{value}" from "rank"}
end

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

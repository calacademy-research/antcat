# coding: UTF-8

Given /^there is a(n invalid)? species described in (\d+)$/ do |invalid, year|
  reference = FactoryGirl.create :article_reference, citation_year: year
  taxon = FactoryGirl.create :species
  taxon.update_attributes! status: 'synonym' if invalid
  taxon.protonym.authorship.update_attributes! reference: reference
end

Then /^I should see the species described in (\d+)$/ do |year|
  step %{I should see "#{year}"}
end

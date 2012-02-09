# coding: UTF-8
Given 'the following species exist' do |table|
  table.hashes.each do |hash|
    Factory :species, hash
  end
end

Given /a (\w+) exists with a name of "([^"]+)" and a parent of "([^"]+)"/ do |rank, name, parent_name|
  Given %{a #{rank} exists with a name of "#{name}"}
  Taxon.find_by_name(name).update_attribute :parent, Taxon.find_by_name(parent_name)
end

When /I follow "All" in the subfamilies list/ do
  step %{I follow "All" within ".subfamilies"}
end

Given /a subfamily exists with a name of "(.*?)" and a taxonomic history of "(.*?)"/ do |taxon_name, taxonomic_history|
  Factory :subfamily, :name => taxon_name, :taxonomic_history => taxonomic_history
end

Given /a tribe exists with a name of "(.*?)"(?: and a subfamily of "(.*?)")?(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history|
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || Factory(:subfamily, :name => parent_name))
  Factory :tribe, :name => taxon_name, :subfamily => subfamily, :taxonomic_history => taxonomic_history
end

Given /a genus exists with a name of "(.*?)" and a subfamily of "(.*?)"(?: and a taxonomic history of "(.*?)")?(?: and a status of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history, status|
  status ||= 'valid'
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || Factory(:subfamily, :name => parent_name))
  Factory :genus, :name => taxon_name, :subfamily => subfamily, :tribe => nil, :taxonomic_history => taxonomic_history, :status => status
end

Given /a genus exists with a name of "(.*?)" and no subfamily(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, taxonomic_history|
  genus = Factory :genus, :name => taxon_name, :subfamily => nil, :tribe => nil, :taxonomic_history => taxonomic_history
end

Given /a (fossil )?genus exists with a name of "(.*?)" and a tribe of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |fossil, taxon_name, parent_name, taxonomic_history|
  tribe = Tribe.find_by_name(parent_name)
  Factory :genus, :name => taxon_name, :subfamily => tribe.subfamily, :tribe => tribe, :taxonomic_history => taxonomic_history, :fossil => fossil.present?
end

Given /a genus that was replaced by "(.*?)" exists with a name of "(.*?)" with a taxonomic history of "(.*?)"/ do |replacement, name, taxonomic_history|
  replacement = Genus.find_by_name(replacement) || Factory(:genus, :name => replacement)
  Factory :genus, :name => name, :taxonomic_history => taxonomic_history, :status => 'homonym', :subfamily => replacement.subfamily, :homonym_replaced_by => replacement
end

Given /a genus that was synonymized to "(.*?)" exists with a name of "(.*?)" with a taxonomic history of "(.*?)"/ do |senior_synonym, name, taxonomic_history|
  senior_synonym = Genus.find_by_name(senior_synonym) || Factory(:genus, :name => senior_synonym)
  Factory :genus, :name => name, :taxonomic_history => taxonomic_history, :status => 'synonym', :subfamily => senior_synonym.subfamily, :synonym_of => senior_synonym
end

Given /a species exists with a name of "(.*?)" and a genus of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history|
  genus = Genus.find_by_name(parent_name) || Factory(:genus, :name => parent_name)
  Factory :species, :name => taxon_name, :genus => genus, :taxonomic_history => taxonomic_history
end

Then /the browser header should be "(.*?)"/ do |contents|
  words = contents.split ' '
  page.should have_css '#browser .header .taxon_header', :text => words.first
  page.should have_css '#browser .header .taxon_header span', :text => words.second
end

Then /I should not see "(.*?)" by itself in the browser/ do |contents|
  page.should_not have_css('.taxon_header a', :text => contents)
end

Then /"(.*?)" tab should be selected/ do |tab|
  page.should have_css ".catalog_view_selector input[checked=checked][value=#{tab}]"
end

Then /I should be in "(.*?)" mode/ do |mode|
  step %{the "#{mode}" tab should be selected}
end

And /I hide tribes/ do
  step %{I follow "hide"}
end


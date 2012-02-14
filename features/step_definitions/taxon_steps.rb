# coding: UTF-8
Given /^the Formicidae family exists$/ do
  Taxon.delete_all
  Protonym.delete_all
  Citation.delete_all
  ForwardReference.delete_all
  Reference.delete_all
  TaxonomicHistoryItem.delete_all

  Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Latreille, I.')], :citation_year => '1809', :title => 'Ants', :bolton_key_cache => 'Latreille 1809'

  family = Family.import( 
    :protonym => {
      :family_or_subfamily_name => "Formicariae",
      :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
    },
    :type_genus => {:genus_name => 'Formica'},
    :taxonomic_history => ['Taxonomic history']
  )
  ForwardReference.fixup
end

Given 'the following species exist' do |table|
  table.hashes.each do |hash|
    Factory :species, hash
  end
end

Given /a (\w+) exists with a name of "([^"]+)" and a parent of "([^"]+)"/ do |rank, name, parent_name|
  Given %{a #{rank} exists with a name of "#{name}"}
  Taxon.find_by_name(name).update_attribute :parent, Taxon.find_by_name(parent_name)
end

Given /a subfamily exists with a name of "(.*?)" and a taxonomic history of "(.*?)"/ do |taxon_name, taxonomic_history|
  taxon = Factory :subfamily, :name => taxon_name
  taxon.taxonomic_history_items.create! :taxt => taxonomic_history
end

Given /a tribe exists with a name of "(.*?)"(?: and a subfamily of "(.*?)")?(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history|
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || Factory(:subfamily, :name => parent_name))
  taxon = Factory :tribe, :name => taxon_name, :subfamily => subfamily
  taxon.taxonomic_history_items.create! :taxt => taxonomic_history
end

Given /a genus exists with a name of "(.*?)" and a subfamily of "(.*?)"(?: and a taxonomic history of "(.*?)")?(?: and a status of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history, status|
  status ||= 'valid'
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || Factory(:subfamily, :name => parent_name))
  taxon =Factory :genus, :name => taxon_name, :subfamily => subfamily, :tribe => nil, :status => status
  taxon.taxonomic_history_items.create! :taxt => taxonomic_history 
end

Given /a genus exists with a name of "(.*?)" and no subfamily(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, taxonomic_history|
  genus = Factory :genus, :name => taxon_name, :subfamily => nil, :tribe => nil
  genus.taxonomic_history_items.create! :taxt => taxonomic_history
end

Given /a (fossil )?genus exists with a name of "(.*?)" and a tribe of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |fossil, taxon_name, parent_name, taxonomic_history|
  tribe = Tribe.find_by_name(parent_name)
  taxon = Factory :genus, :name => taxon_name, :subfamily => tribe.subfamily, :tribe => tribe, :fossil => fossil.present?
  taxon.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a genus that was replaced by "(.*?)" exists with a name of "(.*?)" with a taxonomic history of "(.*?)"/ do |replacement, name, taxonomic_history|
  replacement = Genus.find_by_name(replacement) || Factory(:genus, :name => replacement)
  taxon = Factory :genus, :name => name, :status => 'homonym', :subfamily => replacement.subfamily, :homonym_replaced_by => replacement
  taxon.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a genus that was synonymized to "(.*?)" exists with a name of "(.*?)" with a taxonomic history of "(.*?)"/ do |senior_synonym, name, taxonomic_history|
  senior_synonym = Genus.find_by_name(senior_synonym) || Factory(:genus, :name => senior_synonym)
  taxon = Factory :genus, :name => name, :status => 'synonym', :subfamily => senior_synonym.subfamily, :synonym_of => senior_synonym
  taxon.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a species exists with a name of "(.*?)" and a genus of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history|
  genus = Genus.find_by_name(parent_name) || Factory(:genus, :name => parent_name)
  taxon = Factory :species, :name => taxon_name, :genus => genus
  taxon.taxonomic_history_items.create!  taxt: taxonomic_history
end

Given /a (\w+) exists with a name of "([^"]+)" and a parent of "([^"]+)"/ do |rank, name, parent_name|
  Given %{a #{rank} exists with a name of "#{name}"}
  Taxon.find_by_name(name).update_attribute :parent, Taxon.find_by_name(parent_name)
end


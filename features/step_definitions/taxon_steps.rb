# coding: UTF-8
Given /^the Formicidae family exists$/ do
  Taxon.destroy_all
  SpeciesForwardRef.destroy_all
  Reference.destroy_all

  Factory :article_reference, author_names: [Factory(:author_name, name: 'Latreille, I.')], citation_year: '1809', title: 'Ants', bolton_key_cache: 'Latreille 1809'

  family = Family.import( 
    protonym: {
      family_or_subfamily_name: "Formicariae",
      authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}],
    },
    type_genus: {genus_name: 'Formica'},
    taxonomic_history: ['Taxonomic history']
  )
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
  name = FactoryGirl.create :subfamily_name, name: taxon_name
  taxon = FactoryGirl.create :subfamily, name: name
  taxon.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a tribe exists with a name of "(.*?)"(?: and a subfamily of "(.*?)")?(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history|
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || Factory(:subfamily, name: FactoryGirl.create(:name, name: parent_name)))
  taxon = Factory :tribe, name: FactoryGirl.create(:name, name: taxon_name), subfamily: subfamily
  taxonomic_history = 'none' unless taxonomic_history.present?
  taxon.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a genus exists with a name of "(.*?)" and a subfamily of "(.*?)"(?: and a taxonomic history of "(.*?)")?(?: and a status of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history, status|
  status ||= 'valid'
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || Factory(:subfamily, name: FactoryGirl.create(:name, name: parent_name)))
  taxon =Factory :genus, name: FactoryGirl.create(:name, name: taxon_name), subfamily: subfamily, tribe: nil, status: status
  taxonomic_history = 'none' unless taxonomic_history.present?
  taxon.taxonomic_history_items.create! taxt: taxonomic_history 
end

Given /a genus exists with a name of "(.*?)" and no subfamily(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, taxonomic_history|
  genus = Factory :genus, name: FactoryGirl.create(:genus_name, name: taxon_name), subfamily: nil, tribe: nil
  taxonomic_history = 'none' unless taxonomic_history.present?
  genus.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a (fossil )?genus exists with a name of "(.*?)" and a tribe of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |fossil, taxon_name, parent_name, taxonomic_history|
  tribe = Tribe.find_by_name(parent_name)
  taxonomic_history = 'none' unless taxonomic_history.present?
  taxon = Factory :genus, name: FactoryGirl.create(:name, name: taxon_name), subfamily: tribe.subfamily, tribe: tribe, fossil: fossil.present?
  taxon.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a genus that was replaced by "(.*?)" exists with a name of "(.*?)" with a taxonomic history of "(.*?)"/ do |replacement, name, taxonomic_history|
  replacement = Genus.find_by_name(replacement) || Factory(:genus, name: FactoryGirl.create(:name, name: replacement))
  taxon = Factory :genus, name: FactoryGirl.create(:name, name: name), status: 'homonym', subfamily: replacement.subfamily, homonym_replaced_by: replacement
  taxon.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a genus that was synonymized to "(.*?)" exists with a name of "(.*?)" with a taxonomic history of "(.*?)"/ do |senior_synonym, name, taxonomic_history|
  senior_synonym = Genus.find_by_name(senior_synonym) || Factory(:genus, name: FactoryGirl.create(:name, name: senior_synonym))
  taxon = Factory :genus, name: FactoryGirl.create(:name, name: name), status: 'synonym', subfamily: senior_synonym.subfamily, synonym_of: senior_synonym
  taxon.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a subgenus exists with a name of "(.*?)"(?: and a genus of "(.*?)")?(?: and a taxonomic history of "(.*?)")?/ do |epithet, parent_name, taxonomic_history|
  genus = parent_name && (Genus.find_by_name(parent_name) || Factory(:genus, name: FactoryGirl.create(:genus_name, name: parent_name)))
  name = parent_name + ' (' + epithet + ')'
  subgenus = Factory :subgenus, name: FactoryGirl.create(:subgenus_name, name: name, epithet: epithet), genus: genus
  taxonomic_history = 'none' unless taxonomic_history.present?
  subgenus.taxonomic_history_items.create! taxt: taxonomic_history
end

Given /a species exists with a name of "(.*?)" and a genus of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history|
  genus = Genus.find_by_name(parent_name) || Factory(:genus, name: FactoryGirl.create(:genus_name, name: parent_name))
  @species = Factory :species, name: FactoryGirl.create(:species_name, name: "#{parent_name} #{taxon_name}"), genus: genus
  taxonomic_history = 'none' unless taxonomic_history.present?
  @species.taxonomic_history_items.create!  taxt: taxonomic_history
end

Given /a species exists with a name of "(.*?)" and a subgenus of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history|
  subgenus = Subgenus.find_by_name(parent_name) || Factory(:subgenus, name: FactoryGirl.create(:subgenus_name, name: parent_name))
  @species = Factory :species, name: FactoryGirl.create(:species_name, name: "#{parent_name} #{taxon_name}"), subgenus: subgenus, genus: subgenus.genus
  taxonomic_history = 'none' unless taxonomic_history.present?
  @species.taxonomic_history_items.create!  taxt: taxonomic_history
end

Given /a subspecies exists for that species with a name of "(.*?)" and an epithet of "(.*?)" and a taxonomic history of "(.*?)"/ do |name, epithet, history|
  subspecies = Factory :subspecies, name: FactoryGirl.create(:subspecies_name, name: name, epithet: epithet), species: @species, genus: @species.genus
  history = 'none' unless history.present?
  subspecies.taxonomic_history_items.create! taxt: history
end

Given /a (\w+) exists with a name of "([^"]+)" and a parent of "([^"]+)"/ do |rank, name, parent_name|
  Given %{a #{rank} exists with a name of "#{name}"}
  Taxon.find_by_name(name).update_attribute :parent, Taxon.find_by_name(parent_name)
end

##################################################

Given /^subfamily "(.*?)" exists$/ do |name|
  @subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:subfamily_name, name: name)
  @subfamily.taxonomic_history_items.create! taxt: "#{name} history"
end
Given /^tribe "(.*?)" exists in that subfamily$/ do |name|
  @tribe = FactoryGirl.create :tribe, subfamily: @subfamily, name: FactoryGirl.create(:tribe_name, name: name)
  @tribe.taxonomic_history_items.create! taxt: "#{name} history"
end
Given /^genus "(.*?)" exists in that tribe$/ do |name|
  @genus = FactoryGirl.create :genus, subfamily: @subfamily, tribe: @tribe, name: FactoryGirl.create(:genus_name, name: name)
  @genus.taxonomic_history_items.create! taxt: "#{name} history"
end
Given /^subgenus "(.*?)" exists in that genus$/ do |name|
  epithet = name.match(/\((.*?)\)/)[1]
  name = FactoryGirl.create :subgenus_name, name: name, epithet: epithet
  @subgenus = FactoryGirl.create :subgenus, subfamily: @subfamily, tribe: @tribe, genus: @genus, name: name
  @subgenus.taxonomic_history_items.create! taxt: "#{name} history"
end
Given /^species "(.*?)" exists in that subgenus$/ do |name|
  @species = FactoryGirl.create :species, subfamily: @subfamily, genus: @genus, subgenus: @subgenus, name: FactoryGirl.create(:species_name, name: name)
  @species.taxonomic_history_items.create! taxt: "#{name} history"
end
Given /^species "(.*?)" exists in that genus$/ do |name|
  @species = FactoryGirl.create :species, subfamily: @subfamily, genus: @genus, name: FactoryGirl.create(:species_name, name: name)
  @species.taxonomic_history_items.create! taxt: "#{name} history"
end
Given /^subspecies "(.*?)" exists in that species$/ do |name|
  @subspecies = FactoryGirl.create :subspecies, subfamily: @subfamily, genus: @genus, species: @species, name: FactoryGirl.create(:subspecies_name, name: name)
  @subspecies.taxonomic_history_items.create! taxt: "#{name} history"
end

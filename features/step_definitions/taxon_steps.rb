# coding: UTF-8
Given /^the Formicidae family exists$/ do
  Taxon.destroy_all
  ForwardRef.destroy_all
  Reference.destroy_all

  FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Latreille, I.')], citation_year: '1809', title: 'Ants', bolton_key_cache: 'Latreille 1809'

  family = Family.import( 
    protonym: {
      family_or_subfamily_name: "Formicariae",
      authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}],
    },
    type_genus: {genus_name: 'Formica'},
    history: ['Taxonomic history']
  )
end

Given /a (\w+) exists with a name of "([^"]+)" and a parent of "([^"]+)"/ do |rank, name, parent_name|
  Given %{a #{rank} exists with a name of "#{name}"}
  Taxon.find_by_name(name).update_attribute :parent, Taxon.find_by_name(parent_name)
end

#############################
# subfamily
Given /there is a subfamily "(.*?)" with taxonomic history "(.*?)$"/ do |taxon_name, history|
  name = FactoryGirl.create :subfamily_name, name: taxon_name
  taxon = FactoryGirl.create :subfamily, name: name
  taxon.history_items.create! taxt: history
end
Given /there is a subfamily "(.*?)"(?: with a reference section "(.*?)")?/ do |taxon_name, references|
  name = FactoryGirl.create :subfamily_name, name: taxon_name
  taxon = FactoryGirl.create :subfamily, name: name
  taxon.reference_sections.create! references_taxt: references if references
end

#############################
# genus
Given /^there is a genus "([^"]*)"$/ do |name|
  create_genus name
end
Given /^there is a genus "([^"]*)" with taxonomic history "(.*?)"$/ do |name, history|
  genus = create_genus name
  genus.history_items.create! taxt: history
end
Given /^there is a genus "([^"]*)" with protonym name "(.*?)"$/ do |name, protonym_name|
  genus = create_genus name
  genus.protonym.name = Name.find_by_name protonym_name if protonym_name
end
Given /^there is a genus "([^"]*)" with type name "(.*?)"$/ do |name, type_name|
  genus = create_genus name
  genus.type_name = Name.find_by_name type_name
end
Given /^there is a genus "([^"]*)" that is incertae sedis in the subfamily$/ do |name|
  genus = create_genus name
  genus.update_attribute :incertae_sedis_in, 'subfamily'
end
Given /^a genus exists with a name of "(.*?)" and a subfamily of "(.*?)"(?: and a taxonomic history of "(.*?)")?(?: and a status of "(.*?)")?$/ do |taxon_name, parent_name, history, status|
  status ||= 'valid'
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: parent_name)))
  taxon =FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: taxon_name), subfamily: subfamily, tribe: nil, status: status
  history = 'none' unless history.present?
  taxon.history_items.create! taxt: history 
end
Given /a genus exists with a name of "(.*?)" and no subfamily(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, history|
  genus = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: taxon_name), subfamily: nil, tribe: nil
  history = 'none' unless history.present?
  genus.history_items.create! taxt: history
end
Given /a genus that was replaced by "(.*?)" exists with a name of "(.*?)" with a taxonomic history of "(.*?)"/ do |replacement, name, history|
  replacement = Genus.find_by_name(replacement) || FactoryGirl.create(:genus, name: FactoryGirl.create(:name, name: replacement))
  taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: name), status: 'homonym', subfamily: replacement.subfamily, homonym_replaced_by: replacement
  taxon.history_items.create! taxt: history
end
Given /a (fossil )?genus exists with a name of "(.*?)" and a tribe of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |fossil, taxon_name, parent_name, history|
  tribe = Tribe.find_by_name(parent_name)
  history = 'none' unless history.present?
  taxon = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: taxon_name), subfamily: tribe.subfamily, tribe: tribe, fossil: fossil.present?
  taxon.history_items.create! taxt: history
end
Given /^genus "(.*?)" exists in that tribe$/ do |name|
  @genus = FactoryGirl.create :genus, subfamily: @subfamily, tribe: @tribe, name: FactoryGirl.create(:genus_name, name: name)
  @genus.history_items.create! taxt: "#{name} history"
end
Then /^there should be two genera with the name "(.*)"$/ do |name|
  Genus.where(name_cache: name).count.should == 2
end
Given /^there are two genera called "(.*)"$/ do |name|
  create_genus name
  create_genus name, status: 'nomen nudum'
end

###########################
# species
Given /a species exists with a name of "(.*?)" and a genus of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, history|
  genus = Genus.find_by_name(parent_name) || FactoryGirl.create(:genus, name: FactoryGirl.create(:genus_name, name: parent_name))
  @species = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: "#{parent_name} #{taxon_name}"), genus: genus
  history = 'none' unless history.present?
  @species.history_items.create!  taxt: history
end
Given /a species exists with a name of "(.*?)" and a subgenus of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, history|
  subgenus = Subgenus.find_by_name(parent_name) || FactoryGirl.create(:subgenus, name: FactoryGirl.create(:subgenus_name, name: parent_name))
  @species = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: "#{parent_name} #{taxon_name}"), subgenus: subgenus, genus: subgenus.genus
  history = 'none' unless history.present?
  @species.history_items.create!  taxt: history
end
Given /^species "(.*?)" exists in that subgenus$/ do |name|
  @species = FactoryGirl.create :species, subfamily: @subfamily, genus: @genus, subgenus: @subgenus, name: FactoryGirl.create(:species_name, name: name)
  @species.history_items.create! taxt: "#{name} history"
end
Given /^species "(.*?)" exists in that genus$/ do |name|
  @species = FactoryGirl.create :species, subfamily: @subfamily, genus: @genus, name: FactoryGirl.create(:species_name, name: name)
  @species.history_items.create! taxt: "#{name} history"
end
Given /^there is a species "([^"]*)"$/ do |name|
  create_species name
end
Given /^there is a species "([^"]*)" which is a junior synonym of "([^"]*)"$/ do |junior, senior|
  genus = create_genus 'Solenopsis'
  senior = create_species senior, genus: genus
  junior = create_species junior, status: 'synonym', genus: genus
  Synonym.create! senior_synonym: senior, junior_synonym: junior
end

###########################
# tribe
Given /a tribe exists with a name of "(.*?)"(?: and a subfamily of "(.*?)")?(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, history|
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: parent_name)))
  taxon = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: taxon_name), subfamily: subfamily
  history = 'none' unless history.present?
  taxon.history_items.create! taxt: history
end

Given /a subgenus exists with a name of "(.*?)"(?: and a genus of "(.*?)")?(?: and a taxonomic history of "(.*?)")?/ do |epithet, parent_name, history|
  genus = parent_name && (Genus.find_by_name(parent_name) || FactoryGirl.create(:genus, name: FactoryGirl.create(:genus_name, name: parent_name)))
  name = parent_name + ' (' + epithet + ')'
  subgenus = FactoryGirl.create :subgenus, name: FactoryGirl.create(:subgenus_name, name: name, epithet: epithet), genus: genus
  history = 'none' unless history.present?
  subgenus.history_items.create! taxt: history
end

###########################
Given /a subspecies exists for that species with a name of "(.*?)" and an epithet of "(.*?)" and a taxonomic history of "(.*?)"/ do |name, epithet, history|
  subspecies = FactoryGirl.create :subspecies, name: FactoryGirl.create(:subspecies_name, name: name, epithet: epithet, epithets: epithet), species: @species, genus: @species.genus
  history = 'none' unless history.present?
  subspecies.history_items.create! taxt: history
end

Given /a (\w+) exists with a name of "([^"]+)" and a parent of "([^"]+)"/ do |rank, name, parent_name|
  Given %{a #{rank} exists with a name of "#{name}"}
  Taxon.find_by_name(name).update_attribute :parent, Taxon.find_by_name(parent_name)
end

##################################################

Given /^subfamily "(.*?)" exists$/ do |name|
  @subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:subfamily_name, name: name)
  @subfamily.history_items.create! taxt: "#{name} history"
end
Given /^the unavailable subfamily "(.*?)" exists$/ do |name|
  @subfamily = FactoryGirl.create :subfamily, status: 'unavailable', name: FactoryGirl.create(:subfamily_name, name: name)
end
Given /^tribe "(.*?)" exists in that subfamily$/ do |name|
  @tribe = FactoryGirl.create :tribe, subfamily: @subfamily, name: FactoryGirl.create(:tribe_name, name: name)
  @tribe.history_items.create! taxt: "#{name} history"
end
Given /^subgenus "(.*?)" exists in that genus$/ do |name|
  epithet = name.match(/\((.*?)\)/)[1]
  name = FactoryGirl.create :subgenus_name, name: name, epithet: epithet
  @subgenus = FactoryGirl.create :subgenus, subfamily: @subfamily, tribe: @tribe, genus: @genus, name: name
  @subgenus.history_items.create! taxt: "#{name} history"
end
Given /^subspecies "(.*?)" exists in that species$/ do |name|
  @subspecies = FactoryGirl.create :subspecies, subfamily: @subfamily, genus: @genus, species: @species, name: FactoryGirl.create(:subspecies_name, name: name)
  @subspecies.history_items.create! taxt: "#{name} history"
end
Given /^there is a subspecies "([^"]*)" which is a subspecies of "([^"]*)" in the genus "([^"]*)"/ do |subspecies, species, genus|
  genus = create_genus genus
  species = create_species species, genus: genus
  subspecies = create_subspecies subspecies, species: species, genus: genus
end
Given /^there is a family "Formicidae"$/ do
  create_family
end
Given /^there is a species name "([^"]*)"$/ do |name|
  create_name name
end

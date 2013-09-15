# coding: UTF-8
Given /^there is a family "Formicidae"$/ do
  create_family
end
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

#############################
# subfamily
Given /there is a subfamily "([^"]*)" with taxonomic history "([^"]*)"$/ do |taxon_name, history|
  name = FactoryGirl.create :subfamily_name, name: taxon_name
  taxon = FactoryGirl.create :subfamily, name: name
  taxon.history_items.create! taxt: history
end
Given /there is a subfamily "([^"]*)" with a reference section "(.*?)"$/ do |taxon_name, references|
  name = FactoryGirl.create :subfamily_name, name: taxon_name
  taxon = FactoryGirl.create :subfamily, name: name
  taxon.reference_sections.create! references_taxt: references
end
Given /there is a subfamily "([^"]*)"$/ do |taxon_name|
  name = FactoryGirl.create :subfamily_name, name: taxon_name
  @subfamily = FactoryGirl.create :subfamily, name: name
end
Given /^subfamily "(.*?)" exists$/ do |name|
  @subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:subfamily_name, name: name)
  @subfamily.history_items.create! taxt: "#{name} history"
end
Given /^the unavailable subfamily "(.*?)" exists$/ do |name|
  @subfamily = FactoryGirl.create :subfamily, status: 'unavailable', name: FactoryGirl.create(:subfamily_name, name: name)
end

###########################
Given /^there is a tribe "([^"]*)"$/ do |name|
  create_tribe name
end
# tribe
Given /a tribe exists with a name of "(.*?)"(?: and a subfamily of "(.*?)")?(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, history|
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: parent_name)))
  taxon = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: taxon_name), subfamily: subfamily
  history = 'none' unless history.present?
  taxon.history_items.create! taxt: history
end
Given /^tribe "(.*?)" exists in that subfamily$/ do |name|
  @tribe = FactoryGirl.create :tribe, subfamily: @subfamily, name: FactoryGirl.create(:tribe_name, name: name)
  @tribe.history_items.create! taxt: "#{name} history"
end

###########################
# subgenus
Given /^subgenus "(.*?)" exists in that genus$/ do |name|
  epithet = name.match(/\((.*?)\)/)[1]
  name = FactoryGirl.create :subgenus_name, name: name, epithet: epithet
  @subgenus = FactoryGirl.create :subgenus, subfamily: @subfamily, tribe: @tribe, genus: @genus, name: name
  @subgenus.history_items.create! taxt: "#{name} history"
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
Given /^there is a genus "([^"]*)" without protonym authorship$/ do |name|
  protonym = FactoryGirl.create :protonym
  genus = create_genus name, protonym: protonym
  genus.protonym.update_attribute :authorship, nil
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

###########################
# species
Given /^there is a species "([^"]*)"$/ do |name|
  create_species name
end
Given /a species exists with a name of "(.*?)" and a genus of "(.*?)"(?: and a taxonomic history of "(.*?)")?/ do |taxon_name, parent_name, history|
  genus = Genus.find_by_name(parent_name) || FactoryGirl.create(:genus, name: FactoryGirl.create(:genus_name, name: parent_name))
  @species = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: "#{parent_name} #{taxon_name}"), genus: genus
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
Given /^there is a species "([^"]*)" with genus "([^"]*)"$/ do |species_name, genus_name|
  genus = create_genus genus_name
  create_species species_name, genus: genus
end
Given /^there is a subspecies "([^"]*)" with genus "([^"]*)" and no species$/ do |subspecies_name, genus_name|
  genus = create_genus genus_name
  create_subspecies subspecies_name, genus: genus, species: nil
end
Given /^there is a species "([^"]*)"(?: described by "([^"]*)")? which is a junior synonym of "([^"]*)"$/ do |junior, author_name, senior|
  genus = create_genus 'Solenopsis'
  senior = create_species senior, genus: genus
  junior = create_species junior, status: 'synonym', genus: genus
  Synonym.create! senior_synonym: senior, junior_synonym: junior
  make_author_of_taxon junior, author_name if author_name
end

def make_author_of_taxon taxon, author_name
  author = FactoryGirl.create :author
  author_name = FactoryGirl.create :author_name, name: author_name, author: author
  reference = FactoryGirl.create :article_reference, author_names: [author_name]
  taxon.protonym.authorship.update_attributes! reference: reference
end

###########################
# subspecies
Given /^there is a subspecies "([^"]*)"$/ do |name|
  create_subspecies name
end
Given /^there is a subspecies "([^"]*)" which is a subspecies of "([^"]*)"$/ do |subspecies_name, species_name|
  create_subspecies subspecies_name, species: Species.find_by_name(species_name)
end
Given /^there is a subspecies "([^"]*)" without a species/ do |subspecies_name|
  create_subspecies subspecies_name, species: nil
end
Given /a subspecies exists for that species with a name of "(.*?)" and an epithet of "(.*?)" and a taxonomic history of "(.*?)"/ do |name, epithet, history|
  subspecies = FactoryGirl.create :subspecies, name: FactoryGirl.create(:subspecies_name, name: name, epithet: epithet, epithets: epithet), species: @species, genus: @species.genus
  history = 'none' unless history.present?
  subspecies.history_items.create! taxt: history
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

##################################################

Given /^there is a species name "([^"]*)"$/ do |name|
  create_name name
end

Given(/^there is a species "([^"]*)"$/) do |name|
  create_species name
end

Given(/a species exists with a name of "(.*?)" and a genus of "(.*?)"(?: and a taxonomic history of "(.*?)")?/) do |taxon_name, parent_name, history|
  genus = Genus.find_by_name parent_name
  genus ||= create :genus, name: create(:genus_name, name: parent_name)
  @species = create :species,
    name: create(:species_name, name: "#{parent_name} #{taxon_name}"),
    genus: genus
  history = 'none' unless history.present?
  @species.history_items.create! taxt: history
end

Given(/^species "(.*?)" exists in that subgenus$/) do |name|
  @species = create :species,
    subfamily: @subfamily,
    genus: @genus,
    subgenus: @subgenus,
    name: create(:species_name, name: name)
  @species.history_items.create! taxt: "#{name} history"
end

Given(/^species "(.*?)" exists in that genus$/) do |name|
  @species = create :species,
    subfamily: @subfamily,
    genus: @genus,
    name: create(:species_name, name: name)
  @species.history_items.create! taxt: "#{name} history"
end

Given(/^there is an original species "([^"]*)" with genus "([^"]*)"$/) do |species_name, genus_name|
  genus = create_genus genus_name
  create_species species_name,
    genus: genus,
    status: Status['original combination'].to_s
end

Given(/^there is species "([^"]*)" and another species "([^"]*)" shared between protonym genus "([^"]*)" and later genus "([^"]*)"$/) do
|protonym_species_name, valid_species_name, protonym_genus_name, valid_genus_name|
  proto_genus = create_genus protonym_genus_name
  proto_species = create_species protonym_species_name,
    genus: proto_genus,
    status: Status['original combination'].to_s
  later_genus = create_genus valid_genus_name

  create_species valid_species_name,
    genus: later_genus,
    status: Status['valid'].to_s,
    protonym_id: proto_species.id
end

Given(/^there is a species "([^"]*)" with genus "([^"]*)"$/) do |species_name, genus_name|
  genus = create_genus genus_name
  create_species species_name, genus: genus
end

Given(/^there is a subspecies "([^"]*)" with genus "([^"]*)" and no species$/) do |subspecies_name, genus_name|
  genus = create_genus genus_name
  create_subspecies subspecies_name, genus: genus, species: nil
end

Given(/^there is a species "([^"]*)"(?: described by "([^"]*)")? which is a junior synonym of "([^"]*)"$/) do |junior, author_name, senior|
  genus = create_genus 'Solenopsis'
  senior = create_species senior, genus: genus
  junior = create_species junior, status: 'synonym', genus: genus
  create :synonym, senior_synonym: senior, junior_synonym: junior
  make_author_of_taxon junior, author_name if author_name
end

def make_author_of_taxon taxon, author_name
  author = create :author
  author_name = create :author_name, name: author_name, author: author
  reference = create :article_reference, author_names: [author_name]
  taxon.protonym.authorship.update! reference: reference
end

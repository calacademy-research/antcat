Given("there is a species {string}") do |name|
  create_species name
end

Given(/a species exists with a name of "(.*?)" and a genus of "(.*?)"/) do |taxon_name, parent_name|
  genus = Genus.find_by_name parent_name
  genus ||= create :genus, name: create(:genus_name, name: parent_name)
  @species = create :species,
    name: create(:species_name, name: "#{parent_name} #{taxon_name}"),
    genus: genus
end

Given("species {string} exists in that genus") do |name|
  @species = create :species,
    subfamily: @subfamily,
    genus: @genus,
    name: create(:species_name, name: name)
  @species.history_items.create! taxt: "#{name} history"
end

Given("there is an original species {string} with genus {string}") do |species_name, genus_name|
  genus = create_genus genus_name
  create_species species_name,
    genus: genus,
    status: Status::ORIGINAL_COMBINATION
end

Given("there is species {string} and another species {string} shared between protonym genus {string} and later genus {string}") do |protonym_species_name, valid_species_name, protonym_genus_name, valid_genus_name|
  proto_genus = create_genus protonym_genus_name
  proto_species = create_species protonym_species_name,
    genus: proto_genus,
    status: Status::ORIGINAL_COMBINATION
  later_genus = create_genus valid_genus_name

  create_species valid_species_name,
    genus: later_genus,
    status: Status::VALID,
    protonym_id: proto_species.id
end

Given("there is a species {string} with genus {string}") do |species_name, genus_name|
  genus = Genus.find_by(name_cache: genus_name) || create_genus(genus_name)
  create_species species_name, genus: genus
end

Given("there is a subspecies {string} with genus {string} and no species") do |subspecies_name, genus_name|
  genus = create_genus genus_name
  create_subspecies subspecies_name, genus: genus, species: nil
end

Given(/^there is a species "([^"]*)"(?: described by "([^"]*)")? which is a junior synonym of "([^"]*)"$/) do |junior, author_name, senior|
  genus = create_genus 'Solenopsis'
  senior = create_species senior, genus: genus
  junior = create_species junior, status: Status::SYNONYM, genus: genus
  create :synonym, senior_synonym: senior, junior_synonym: junior
  make_author_of_taxon junior, author_name if author_name
end

Given("there is a species with published type information {string}") do |published_type_information|
  create :species, published_type_information: published_type_information
end

def make_author_of_taxon taxon, author_name
  author = create :author
  author_name = create :author_name, name: author_name, author: author
  reference = create :article_reference, author_names: [author_name]
  taxon.protonym.authorship.update! reference: reference
end

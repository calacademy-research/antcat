Given("there is a species {string}") do |name|
  create_species name
end

Given("a species exists with a name of {string} and a genus of {string}") do |name, parent_name|
  genus = Genus.find_by(name_cache: parent_name)
  genus ||= create :genus, name: create(:genus_name, name: parent_name)
  @species = create :species,
    name: create(:species_name, name: "#{parent_name} #{name}"),
    genus: genus
end

Given("there is a species {string} with genus {string}") do |species_name, genus_name|
  genus = Genus.find_by(name_cache: genus_name) || create_genus(genus_name)
  create_species species_name, genus: genus
end

Given("there is a subspecies {string} with genus {string} and no species") do |subspecies_name, genus_name|
  genus = create_genus genus_name
  create_subspecies subspecies_name, genus: genus, species: nil
end

Given("there is a species {string} which is a junior synonym of {string}") do |junior, senior|
  genus = create :genus
  senior = create_species senior, genus: genus
  junior = create_species junior, status: Status::SYNONYM, genus: genus, current_valid_taxon: senior
  create :synonym, senior_synonym: senior, junior_synonym: junior
end

Given("there is a species with primary type information {string}") do |primary_type_information|
  protonym = create :protonym, primary_type_information_taxt: primary_type_information
  create :species, protonym: protonym
end

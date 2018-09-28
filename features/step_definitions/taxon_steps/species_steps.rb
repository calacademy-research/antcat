Given("there is a species {string}") do |name|
  create_species name
end

Given("a species exists with a name of {string} and a genus of {string}") do |name, parent_name|
  genus = Genus.find_by_name parent_name
  genus ||= create :genus, name: create(:genus_name, name: parent_name)
  @species = create :species,
    name: create(:species_name, name: "#{parent_name} #{name}"),
    genus: genus
end

Given("species {string} exists in that genus") do |name|
  @species = create :species,
    subfamily: @subfamily,
    genus: @genus,
    name: create(:species_name, name: name)
end

Given("there is an original species {string} with genus {string}") do |species_name, genus_name|
  genus = create_genus genus_name
  create_species species_name,
    genus: genus,
    status: Status::ORIGINAL_COMBINATION,
    current_valid_taxon: (Family.first || create(:family)) # TODO revisit. Added after adding validations.
end

Given("there is species {string} and another species {string} shared between protonym genus {string} and later genus {string}") do |protonym_species_name, valid_species_name, protonym_genus_name, valid_genus_name|
  proto_genus = create_genus protonym_genus_name
  proto_species = create_species protonym_species_name,
    genus: proto_genus,
    status: Status::ORIGINAL_COMBINATION,
    current_valid_taxon: (Family.first || create(:family)) # TODO revisit. Added after adding validations.
  later_genus = create_genus valid_genus_name

  create_species valid_species_name,
    genus: later_genus,
    protonym_id: proto_species.id # TODO.
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
  create :species, primary_type_information: primary_type_information
end

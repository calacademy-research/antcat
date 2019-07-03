Given("there is a species {string}") do |name|
  create :species, name_string: name
end

Given("there is a species {string} in the genus {string}") do |species_name, genus_name|
  genus = Genus.find_by(name_cache: genus_name) || create(:genus, name_string: genus_name)
  create :species, name_string: species_name, genus: genus
end

Given("there is a species {string} which is a junior synonym of {string}") do |species_name, senior_name|
  senior = create :species, name_string: senior_name
  create :species, :synonym, name_string: species_name, current_valid_taxon: senior
end

Given("there is a species with primary type information {string}") do |primary_type_information|
  protonym = create :protonym, primary_type_information_taxt: primary_type_information
  create :species, protonym: protonym
end

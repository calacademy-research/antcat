# frozen_string_literal: true

def there_is_an_extant_species_lasius_niger_in_a_fossil_genus
  genus = create :genus, protonym: create(:protonym, :genus_group, :fossil)
  create :species, name_string: "Lasius niger", genus: genus
end

def i_open_all_database_scripts_one_by_one
  script_names = DatabaseScript.all.map(&:to_param)
  script_names.each do |script_name|
    i_open_the_database_script script_name.to_s
  end
end

def i_open_the_database_script database_script_name
  visit "/database_scripts/#{database_script_name}"
  i_should_see "Show source" # Anything to confirm the page was rendered.
end

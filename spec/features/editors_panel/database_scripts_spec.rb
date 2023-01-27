# frozen_string_literal: true

require 'rails_helper'

feature "Database scripts", as: :user do
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

  background do
    i_go_to 'the database scripts page'
  end

  scenario "Results when there are issues" do
    there_is_an_extant_species_lasius_niger_in_a_fossil_genus
    i_go_to 'the database scripts page'

    i_follow "Extant taxa in fossil genera"
    i_should_see "Lasius niger"
  end

  scenario "Displaying database script issues in catalog pages" do
    these_settings "catalog: { show_failed_soft_validations: false }"
    there_is_an_extant_species_lasius_niger_in_a_fossil_genus

    i_go_to 'the catalog page for "Lasius niger"'
    i_should_not_see "The parent of this taxon is fossil, but this taxon is extant"

    these_settings "catalog: { show_failed_soft_validations: true }"
    i_reload_the_page
    i_should_see "The parent of this taxon is fossil, but this taxon is extant"

    i_follow_the_first "See more similar."
    i_should_see "Extant taxa in fossil genera"
  end

  scenario "Opening all scripts just to see if the page renders" do
    i_open_all_database_scripts_one_by_one
  end

  scenario "Checking 'empty' status" do
    i_should_not_see "Excluded (slow/list)"

    i_follow "Show empty"
    i_should_see "Excluded (slow/list)"
  end
end

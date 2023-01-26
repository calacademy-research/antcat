# frozen_string_literal: true

require 'rails_helper'

feature "Converting a species to a subspecies" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Converting a species to a subspecies (with feed)" do
    there_is_a_species_in_the_genus "Camponotus dallatorei", "Camponotus"
    there_is_a_species_in_the_genus "Camponotus alii", "Camponotus"

    i_go_to 'the catalog page for "Camponotus dallatorei"'
    i_follow "Convert to subspecies"
    i_should_see "Convert species"
    i_should_see "to be a subspecies of"

    i_pick_from_the_taxon_picker "Camponotus alii", "#new_species_id"
    i_press "Convert"
    i_should_be_on 'the catalog page for "Camponotus alii dallatorei"'
    taxon_should_be_of_the_rank_of "Camponotus alii dallatorei", "subspecies"

    i_go_to 'the activity feed'
    i_should_see "Archibald converted the species Camponotus dallatorei to a subspecies (now Camponotus alii dallatorei)", within: 'the activity feed'
  end

  scenario "Converting a species to a subspecies when it already exists" do
    there_is_a_species_in_the_genus "Camponotus alii", "Camponotus"
    there_is_a_subspecies_in_the_species "Camponotus alii dallatorei", "Camponotus alii"
    there_is_a_species_in_the_genus "Camponotus dallatorei", "Camponotus"

    i_go_to 'the catalog page for "Camponotus dallatorei"'
    i_follow "Convert to subspecies"
    i_pick_from_the_taxon_picker "Camponotus alii", "#new_species_id"
    i_press "Convert"
    i_should_see "This name is in use by another taxon"
  end
end

# frozen_string_literal: true

require 'rails_helper'

feature "Elevating subspecies to species" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
    there_is_a_species_in_the_genus "Solenopsis speccus", "Solenopsis"
    there_is_a_subspecies_in_the_species "Solenopsis speccus subbus", "Solenopsis speccus"
  end

  scenario "Elevating subspecies to species (with feed)" do
    i_go_to 'the catalog page for "Solenopsis speccus subbus"'
    i_will_confirm_on_the_next_step
    i_follow "Elevate to species"
    i_should_see "Subspecies was successfully elevated to a species."
    taxon_should_be_of_the_rank_of "Solenopsis subbus", "species"

    i_go_to 'the activity feed'
    i_should_see "Archibald elevated the subspecies Solenopsis speccus subbus to the rank of species (now Solenopsis subbus)", within: 'the activity feed'
  end

  scenario "Elevating to species when the species name exists" do
    there_is_a_species "Solenopsis subbus"

    i_go_to 'the catalog page for "Solenopsis speccus subbus"'
    i_will_confirm_on_the_next_step
    i_follow "Elevate to species"
    i_should_see "This name is in use by another taxon"
  end
end

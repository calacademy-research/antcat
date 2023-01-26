# frozen_string_literal: true

require 'rails_helper'

feature "Manage subgenera" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Setting and removing a subgenus of a species (with feed)" do
    there_is_a_subgenus_in_the_genus "Camponotus (Myrmentoma)", "Camponotus"
    there_is_a_species_in_the_genus "Camponotus cornis", "Camponotus"

    i_go_to 'the catalog page for "Camponotus cornis"'
    i_should_not_see "Camponotus (Myrmentoma)", within: 'the breadcrumbs'

    i_follow "Set subgenus", within: 'the breadcrumbs'
    i_follow "Set"
    i_should_see "Successfully updated subgenus of species"

    i_go_to 'the catalog page for "Camponotus cornis"'
    i_should_see "Camponotus (Myrmentoma)", within: 'the breadcrumbs'

    i_go_to 'the activity feed'
    i_should_see "Archibald set the subgenus of Camponotus cornis to Camponotus (Myrmentoma)", within: 'the activity feed'

    i_go_to 'the catalog page for "Camponotus cornis"'
    i_follow "Set subgenus", within: 'the breadcrumbs'
    i_follow "Remove"
    i_should_see "Successfully removed subgenus from species"

    i_go_to 'the catalog page for "Camponotus cornis"'
    i_should_not_see "Camponotus (Myrmentoma)", within: 'the breadcrumbs'

    i_go_to 'the activity feed'
    i_should_see "Archibald removed the subgenus from Camponotus cornis (subgenus was Camponotus (Myrmentoma))", within: 'the activity feed'
  end
end

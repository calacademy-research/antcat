# frozen_string_literal: true

require 'rails_helper'

feature "Manage subgenera" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Setting and removing a subgenus of a species (with feed)" do
    genus = create(:genus, name_string: "Camponotus")
    create :subgenus, name_string: "Camponotus (Myrmentoma)", genus: genus
    taxon = create :species, name_string: "Camponotus cornis", genus: genus

    visit catalog_path(taxon)
    i_should_not_see "Camponotus (Myrmentoma)", within: 'the breadcrumbs'

    i_follow "Set subgenus", within: 'the breadcrumbs'
    i_follow "Set"
    i_should_see "Successfully updated subgenus of species"

    visit catalog_path(taxon)
    i_should_see "Camponotus (Myrmentoma)", within: 'the breadcrumbs'

    there_should_be_an_activity "Archibald set the subgenus of Camponotus cornis to Camponotus \\(Myrmentoma\\)"

    visit catalog_path(taxon)
    i_follow "Set subgenus", within: 'the breadcrumbs'
    i_follow "Remove"
    i_should_see "Successfully removed subgenus from species"

    visit catalog_path(taxon)
    i_should_not_see "Camponotus (Myrmentoma)", within: 'the breadcrumbs'

    there_should_be_an_activity "Archibald removed the subgenus from Camponotus cornis \\(subgenus was Camponotus \\(Myrmentoma\\)\\)"
  end
end

# frozen_string_literal: true

require 'rails_helper'

feature "Move items", :skip_ci do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Moving reference sections (with feed)", :js do
    move_from_taxon = create :subfamily, name_string: "Antcatinae"
    create :reference_section, references_taxt: "Antcatinae section", taxon: move_from_taxon

    move_to_taxon = create :genus, name_string: "Formica"

    visit catalog_path(move_from_taxon)
    i_follow "Move items"
    i_should_see "Move items › Select target"

    click_button "Select..."
    i_should_see "Target must be specified"

    i_pick_from_the_taxon_picker "Formica", "#to_taxon_id"
    click_button "Select..."
    i_should_see "Move items › to Formica"

    click_button "Move selected items"
    i_should_see "At least one item must be selected"

    find(:testid, 'select-deselect-all-button').click
    click_button "Move selected items"
    i_should_see "Successfully moved items"

    visit catalog_path(move_to_taxon)
    i_should_see "Antcatinae section"

    there_should_be_an_activity "Archibald moved items belonging to Antcatinae to Formica"
  end

  scenario "Moving history items (with feed)", :js do
    move_from_protonym = create :protonym, :family_group, name: create(:subfamily_name, name: "Antcatinae")
    create :history_item, :taxt, taxt: "Antcatinae history", protonym: move_from_protonym

    move_to_protonym = create :protonym, :genus_group, name: create(:genus_name, name: "Formica")

    visit protonym_path(move_from_protonym)
    i_follow "Move items"
    i_should_see "Move items › Select target"

    click_button "Select..."
    i_should_see "Target must be specified"

    i_pick_from_the_protonym_picker "Formica", "#to_protonym_id"
    click_button "Select..."
    i_should_see "Move items › to Formica"

    click_button "Move selected items"
    i_should_see "At least one item must be selected"

    find(:testid, 'select-deselect-all-button').click
    click_button "Move selected items"
    i_should_see "Successfully moved items"

    visit protonym_path(move_to_protonym)
    i_should_see "Antcatinae history"

    there_should_be_an_activity "Archibald moved protonym items belonging to Antcatinae \\(no terminal taxon\\) to Formica"
  end
end

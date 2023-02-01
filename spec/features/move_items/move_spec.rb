# frozen_string_literal: true

require 'rails_helper'

feature "Move items" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Moving reference sections (with feed)", :js do
    subfamily_with_reference_section = create :subfamily, name_string: "Antcatinae"
    create :reference_section, references_taxt: "Antcatinae section", taxon: subfamily_with_reference_section

    create :genus, name_string: "Formica"

    i_go_to 'the catalog page for "Antcatinae"'
    i_follow "Move items"
    i_should_see "Move items › Select target"

    click_button "Select..."
    i_should_see "Target must be specified"

    i_pick_from_the_taxon_picker "Formica", "#to_taxon_id"
    click_button "Select..."
    i_should_see "Move items › to Formica"

    click_button "Move selected items"
    i_should_see "At least one item must be selected"

    i_click_css_with_text "span.btn-tiny", "Select/deselect all"
    click_button "Move selected items"
    i_should_see "Successfully moved items"

    i_go_to 'the catalog page for "Formica"'
    i_should_see "Antcatinae section"

    there_should_be_an_activity "Archibald moved items belonging to Antcatinae to Formica"
  end

  scenario "Moving history items (with feed)", :js do
    subfamily_protonym_with_history_item = create :protonym, :family_group, name: create(:subfamily_name, name: "Antcatinae")
    create :history_item, :taxt, taxt: "Antcatinae history", protonym: subfamily_protonym_with_history_item

    there_is_a_genus_protonym "Formica"

    i_go_to 'the protonym page for "Antcatinae"'
    i_follow "Move items"
    i_should_see "Move items › Select target"

    click_button "Select..."
    i_should_see "Target must be specified"

    i_pick_from_the_protonym_picker "Formica", "#to_protonym_id"
    click_button "Select..."
    i_should_see "Move items › to Formica"

    click_button "Move selected items"
    i_should_see "At least one item must be selected"

    i_click_css_with_text "span.btn-tiny", "Select/deselect all"
    click_button "Move selected items"
    i_should_see "Successfully moved items"

    i_go_to 'the protonym page for "Formica"'
    i_should_see "Antcatinae history"

    there_should_be_an_activity "Archibald moved protonym items belonging to Antcatinae \\(no terminal taxon\\) to Formica"
  end
end

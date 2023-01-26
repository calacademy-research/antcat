# frozen_string_literal: true

require 'rails_helper'

feature "Move items" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Moving reference sections (with feed)", :js do
    there_is_a_subfamily_with_a_reference_section "Antcatinae", "Antcatinae section"
    there_is_a_genus "Formica"

    i_go_to 'the catalog page for "Antcatinae"'
    i_follow "Move items"
    i_should_see "Move items › Select target"

    i_press "Select..."
    i_should_see "Target must be specified"

    i_pick_from_the_taxon_picker "Formica", "#to_taxon_id"
    i_press "Select..."
    i_should_see "Move items › to Formica"

    i_press "Move selected items"
    i_should_see "At least one item must be selected"

    i_click_css_with_text "span.btn-tiny", "Select/deselect all"
    i_press "Move selected items"
    i_should_see "Successfully moved items"

    i_go_to 'the catalog page for "Formica"'
    i_should_see "Antcatinae section"

    i_go_to 'the activity feed'
    i_should_see "Archibald moved items belonging to Antcatinae to Formica", within: 'the activity feed'
  end

  scenario "Moving history items (with feed)", :js do
    there_is_a_subfamily_protonym_with_a_history_item "Antcatinae", "Antcatinae history"
    there_is_a_genus_protonym "Formica"

    i_go_to 'the protonym page for "Antcatinae"'
    i_follow "Move items"
    i_should_see "Move items › Select target"

    i_press "Select..."
    i_should_see "Target must be specified"

    i_pick_from_the_protonym_picker "Formica", "#to_protonym_id"
    i_press "Select..."
    i_should_see "Move items › to Formica"

    i_press "Move selected items"
    i_should_see "At least one item must be selected"

    i_click_css_with_text "span.btn-tiny", "Select/deselect all"
    i_press "Move selected items"
    i_should_see "Successfully moved items"

    i_go_to 'the protonym page for "Formica"'
    i_should_see "Antcatinae history"

    i_go_to 'the activity feed'
    i_should_see "Archibald moved protonym items belonging to Antcatinae (no terminal taxon) to Formica", within: 'the activity feed'
  end
end

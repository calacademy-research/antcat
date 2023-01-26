# frozen_string_literal: true

require 'rails_helper'

feature "Markdown autocompletion", :js do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "References markdown autocompletion", :skip_ci, :search do
    this_reference_exists author: "Giovanni, S.", title: "Giovanni's Favorite Ants", year: 1810
    this_reference_exists author: "Joffre, J.", title: "Joffre's Favorite Ants", year: 1810
    Sunspot.commit

    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    i_fill_in "issue_description", with: "{rfav"
    i_should_see "Giovanni's Favorite Ants"
    i_should_see "Joffre's Favorite Ants"

    i_clear_the_markdown_textarea
    i_should_not_see "Favorite Ants"

    i_fill_in "issue_description", with: "{rjof"
    i_click_the_suggestion_containing "Joffre's Favorite Ants"
    the_markdown_textarea_should_contain_a_markdown_link_to "Joffre, 1810"
  end

  scenario "Taxa markdown autocompletion", :skip_ci, :search do
    there_is_a_genus "Eciton"
    there_is_a_genus "Atta"
    Sunspot.commit
    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    i_fill_in "issue_description", with: "{tec"
    i_should_see "Eciton"

    i_click_the_suggestion_containing "Eciton"
    the_markdown_textarea_should_contain_a_markdown_link_to_eciton
  end

  scenario "User markdown autocompletion", :skip_ci do
    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    i_fill_in "issue_description", with: "@arch"
    i_click_the_suggestion_containing "Archibald"
    the_markdown_textarea_should_contain_a_markdown_link_to_archibalds_user_page
  end
end

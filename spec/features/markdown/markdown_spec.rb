# frozen_string_literal: true

require 'rails_helper'

feature "Markdown" do
  background do
    i_log_in_as_a_catalog_editor
  end

  scenario "Using markdown" do
    there_is_an_open_issue "Merge 'Giovanni' authors"
    this_reference_exists author: " Giovanni, S.", year: 1809
    this_reference_exists author: "Giovanni, S.", year: 1809
    i_go_to %(the issue page for "Merge 'Giovanni' authors")
    i_follow "Edit"
    i_fill_in_with_and_a_markdown_link_to "issue_description", "See:", "Giovanni, 1809"
    i_press "Save"
    i_should_see "See: Giovanni, 1809"
  end
end

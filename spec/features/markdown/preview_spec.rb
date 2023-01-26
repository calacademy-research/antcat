# frozen_string_literal: true

require 'rails_helper'

feature "Preview markdown", :skip_ci, :js do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Previewing references markdown" do
    this_reference_exists author: "Giovanni, S. ", year: 1809
    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    i_fill_in_with_and_a_markdown_link_to "issue_description", "See:", "Giovanni, 1809"
    i_press "Rerender preview"
    i_should_see "See: Giovanni, 1809"
  end
end

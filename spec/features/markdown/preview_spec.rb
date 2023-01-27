# frozen_string_literal: true

require 'rails_helper'

feature "Preview markdown", as: :editor, skip_ci: true, js: true do
  scenario "Previewing references markdown" do
    create :any_reference, author_string: "Giovanni, S. ", year: 1809
    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    i_fill_in_with_and_a_markdown_link_to "issue_description", "See:", "Giovanni, 1809"
    click_button "Rerender preview"
    i_should_see "See: Giovanni, 1809"
  end
end

# frozen_string_literal: true

require 'rails_helper'

feature "Markdown", as: :editor do
  scenario "Using markdown" do
    create :issue, :open, title: "Merge 'Giovanni' authors"
    create :any_reference, author_string: " Giovanni, S.", year: 1809
    create :any_reference, author_string: "Giovanni, S.", year: 1809

    i_go_to %(the issue page for "Merge 'Giovanni' authors")
    i_follow "Edit"
    i_fill_in_with_and_a_markdown_link_to "issue_description", "See:", "Giovanni, 1809"
    click_button "Save"
    i_should_see "See: Giovanni, 1809"
  end
end

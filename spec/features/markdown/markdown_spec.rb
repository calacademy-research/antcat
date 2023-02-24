# frozen_string_literal: true

require 'rails_helper'

feature "Markdown", as: :editor do
  scenario "Using markdown" do
    issue = create :issue, :open, title: "Merge 'Giovanni' authors"
    giovanni_1809 = create :any_reference, author_string: "Giovanni, S.", year: 1809

    visit issue_path(issue)
    i_follow "Edit"
    fill_in "issue_description", with: "See: #{Taxt.ref(giovanni_1809.id)}"
    click_button "Save"
    i_should_see "See: Giovanni, 1809"
  end
end

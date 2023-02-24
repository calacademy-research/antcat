# frozen_string_literal: true

require 'rails_helper'

feature "Preview markdown", as: :editor, skip_ci: true, js: true do
  scenario "Previewing references markdown" do
    giovanni_1809 = create :any_reference, author_string: "Giovanni, S. ", year: 1809

    i_go_to 'the open issues page'
    i_follow "New"
    fill_in "issue_description", with: "See: #{Taxt.ref(giovanni_1809.id)}"
    click_button "Rerender preview"
    i_should_see "See: Giovanni, 1809"
  end
end

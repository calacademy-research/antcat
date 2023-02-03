# frozen_string_literal: true

require 'rails_helper'

feature "Commenting" do
  background do
    i_log_in_as_a_catalog_editor_named "Batiatus"
    create :feedback, user: nil
    i_go_to 'the most recent feedback item'
  end

  scenario "Leaving a comment (with feed)" do
    i_write_a_new_comment "Fixed, closing issue."
    click_button "Post Comment"
    i_should_see "Comment was successfully added"
    i_should_see "Fixed, closing issue."

    there_should_be_an_activity "Batiatus commented on the feedback #"
  end
end

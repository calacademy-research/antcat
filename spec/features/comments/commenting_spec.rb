# frozen_string_literal: true

require 'rails_helper'

feature "Commenting" do
  background do
    i_log_in_as_a_catalog_editor_named "Batiatus"
    there_is_an_open_feedback_item
    i_go_to 'the most recent feedback item'
  end

  scenario "Leaving a comment (with feed)" do
    i_write_a_new_comment "Fixed, closing issue."
    i_press "Post Comment"
    i_should_see "Comment was successfully added"
    i_should_see "Fixed, closing issue."

    i_go_to 'the activity feed'
    i_should_see "Batiatus commented on the feedback #"
  end
end

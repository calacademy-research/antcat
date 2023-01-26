# frozen_string_literal: true

require 'rails_helper'

feature "Browse recent comments" do
  background do
    i_log_in_as_a_catalog_editor_named "Batiatus"
  end

  scenario "Parse AntCat markdown of truncated comments" do
    there_is_an_open_issue_created_by "Test markdown", "Batiatus"

    i_go_to 'the issue page for "Test markdown"'
    i_write_a_new_comment_at_batiatus_id "your name should be linked."
    i_press "Post Comment"
    i_wait_for_the_success_message

    i_go_to 'the comments page'
    i_should_see "Batiatus commented on the issue Test markdown:"
    i_should_see "@Batiatus your name should be linked."
  end
end

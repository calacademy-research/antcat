# frozen_string_literal: true

require 'rails_helper'

feature "Managing user feedback", %(
  As an AntCat editor
  I want to open/close user feedback items
  So that editors can track issues
) do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Closing a feedback item (with feed)" do
    create :feedback, user: nil

    i_go_to 'the most recent feedback item'
    i_should_not_see "Re-open"

    i_follow "Close"
    i_should_see "Successfully closed feedback item."
    i_should_see "Re-open"
    i_should_not_see "Close"

    i_go_to 'the activity feed'
    i_should_see "Archibald closed the feedback item #"
  end

  scenario "Re-opening a closed feedback item (with feed)" do
    create :feedback, :closed

    i_go_to 'the most recent feedback item'
    i_follow "Re-open"
    i_should_see "Successfully re-opened feedback item."
    i_should_see "Close"
    i_should_not_see "Re-open"

    i_go_to 'the activity feed'
    i_should_see "Archibald re-opened the feedback item #"
  end
end

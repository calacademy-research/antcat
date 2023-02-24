# frozen_string_literal: true

require 'rails_helper'

feature "Managing user feedback" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Closing a feedback item (with feed)" do
    feedback = create :feedback

    visit feedback_path(feedback)
    i_should_not_see "Re-open"

    i_follow "Close"
    i_should_see "Successfully closed feedback item."
    i_should_see "Re-open"
    i_should_not_see "Close"

    there_should_be_an_activity "Archibald closed the feedback item #"
  end

  scenario "Re-opening a closed feedback item (with feed)" do
    feedback = create :feedback, :closed

    visit feedback_path(feedback)
    i_follow "Re-open"
    i_should_see "Successfully re-opened feedback item."
    i_should_see "Close"
    i_should_not_see "Re-open"

    there_should_be_an_activity "Archibald re-opened the feedback item #"
  end
end

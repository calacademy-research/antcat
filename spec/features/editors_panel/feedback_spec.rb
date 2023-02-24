# frozen_string_literal: true

require 'rails_helper'

feature "feedback" do
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

  feature "Submit feedback" do
    background do
      visit root_path
    end

    scenario "Nothing except a comment is required", as: :visitor do
      i_follow "Suggest edit"
      click_button "Send Feedback"
      i_should_see "Comment can't be blank"

      fill_in "feedback_comment", with: "Great site!!!"
      click_button "Send Feedback"
      i_should_see "Message sent"
    end

    scenario "Unregistered user submitting feedback (with feed)", as: :visitor do
      i_follow "Suggest edit"
      fill_in "feedback_comment", with: "Great site!!!"
      click_button "Send Feedback"

      i_should_see "Message sent"
      i_should_see "Thanks for helping us make AntCat better!"

      i_log_in_as_a_catalog_editor
      visit feedbacks_path
      i_should_see "[no name] <[no email];"

      there_should_be_an_activity "An unregistered user added the feedback item #"
    end

    scenario "Registered user submitting feedback (with feed)" do
      i_log_in_as_a_catalog_editor_named "Archibald"

      i_follow "Suggest edit"
      fill_in "feedback_comment", with: "Great site!!!"
      click_button "Send Feedback"
      i_should_see "Message sent"

      visit feedbacks_path
      i_should_see "Archibald submitted"

      there_should_be_an_activity "Archibald added the feedback item #"
    end

    scenario "Page field defaults to the current URL", as: :visitor do
      taxon = create :genus

      visit catalog_path(taxon)
      i_follow "Suggest edit"
      the_field_should_contain "feedback_page", "catalog/#{taxon.id}"
    end
  end
end

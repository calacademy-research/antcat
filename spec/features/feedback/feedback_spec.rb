# frozen_string_literal: true

require 'rails_helper'

feature "Feedback", %(
  As an user or editor of AntCat
  I want to submit feedback and corrections
  So that we can improve the catalog
) do
  background do
    i_go_to 'the catalog'
  end

  scenario "Nothing except a comment is required" do
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
    i_go_to 'the feedback page'
    i_should_see "[no name] <[no email];"

    there_should_be_an_activity "An unregistered user added the feedback item #"
  end

  scenario "Registered user submitting feedback (with feed)" do
    i_log_in_as_a_catalog_editor_named "Archibald"

    i_follow "Suggest edit"
    fill_in "feedback_comment", with: "Great site!!!"
    click_button "Send Feedback"
    i_should_see "Message sent"

    i_go_to 'the feedback page'
    i_should_see "Archibald submitted"

    there_should_be_an_activity "Archibald added the feedback item #"
  end

  scenario "Page field defaults to the current URL" do
    create :genus, name_string: "Calyptites"

    i_go_to 'the catalog page for "Calyptites"'
    i_follow "Suggest edit"
    the_field_should_contain "feedback_page", "catalog/"
  end
end

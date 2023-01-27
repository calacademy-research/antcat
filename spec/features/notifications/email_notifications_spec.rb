# frozen_string_literal: true

require 'rails_helper'

# TODO: Skipped due to "NoMethodError: undefined method `unread_emails_for' for #<RSpec...".
xfeature "Email notifications" do
  def email_should_have_number_of_unread_emails address, amount
    expect(unread_emails_for(address).size).to eq parse_email_count(amount)
  end

  def email_should_see_in_the_email_body _address, text
    expect(current_email.default_part_body.to_s).to include(text)
  end

  def email_opens_the_email_with_subject address, subject
    open_email(address, with_subject: subject)
  end

  background do
    i_log_in_as_a_user_named "Quintus"
    create :user, email: "batiatus@antcat.org", name: "Batiatus"
    these_settings 'email: { enabled: true }'
  end

  scenario "Receiving emails notifications" do
    there_is_an_open_issue_created_by "Ghost Stories", "Batiatus"
    email_should_have_number_of_unread_emails "batiatus@antcat.org", 0

    # Mention Batiatus in a comment.
    i_go_to 'the issue page for "Ghost Stories"'
    i_write_a_new_comment_at_batiatus_id "nice ghost story!"
    click_button "Post Comment"
    i_wait_for_the_success_message
    i_follow "Logout", within: 'the desktop menu'
    i_should_not_see "Quintus"

    email_should_have_number_of_unread_emails "batiatus@antcat.org", 1
    email_opens_the_email_with_subject "batiatus@antcat.org", "New notification - antcat.org"
    email_should_see_in_the_email_body "batiatus@antcat.org", "mentioned you in a comment on the"
  end
end

# frozen_string_literal: true

require 'rails_helper'

feature "User notifications" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
    this_user_exists name: "Batiatus"
  end

  scenario "No notifications" do
    i_go_to 'my notifications page'
    i_should_see "No notifications"
  end

  scenario "Opening the notifications page marks all notifications as seen" do
    i_have_an_unseen_notification

    i_go_to 'the references page'
    i_should_see "1 new notification!"

    i_go_to 'my notifications page'
    i_should_see_number_of_unread_notifications 1

    i_have_another_unseen_notification
    i_reload_the_page
    i_should_see_number_of_unread_notifications 1
    i_should_see_number_of_notification 2
  end

  scenario "Mentioning users in comments" do
    # Create issue by a third user.
    this_user_exists name: "Captain Flint"
    there_is_an_open_issue_created_by "Ghost Stories", "Captain Flint"

    # Mention Batiatus in a comment.
    i_go_to 'the issue page for "Ghost Stories"'
    i_write_a_new_comment_at_batiatus_id "you must read Flint's ghost story!"
    i_press "Post Comment"
    i_wait_for_the_success_message

    # Confirm Batiatus was notified.
    i_log_in_as "Batiatus"
    i_go_to 'my notifications page'
    i_should_see "Archibald mentioned you in the comment on the issue Ghost Stories"
    i_should_see_number_of_notification 1
  end

  scenario "Notifying creators, and replying to comments (without mentioning their names)" do
    there_is_an_open_issue_created_by "My Favorite Ants", "Batiatus"

    # Comment on an issue created by Batiatus.
    i_go_to 'the issue page for "My Favorite Ants"'
    i_write_a_new_comment "Great list, Batiatus!"
    i_press "Post Comment"
    i_wait_for_the_success_message

    # Confirm Batiatus was notified.
    i_log_in_as "Batiatus"
    i_go_to 'my notifications page'
    i_should_see "Archibald commented on the issue My Favorite Ants which you created"
    i_should_see_number_of_notification 1

    # Reply to Archibald's comment as Batiatus.
    i_go_to 'the issue page for "My Favorite Ants"'
    i_write_a_new_comment "Thanks, Archibald!"
    i_press "Post Comment"
    i_wait_for_the_success_message

    # Confirm Archibald was notified.
    i_log_in_as "Archibald"
    i_go_to 'my notifications page'
    i_should_see "Batiatus commented on the issue My Favorite Ants which you also have commented"
    i_should_see_number_of_notification 1
  end

  scenario "Send at most one notification to a user for the same comment" do
    # Make Batiatus the issue creator and a participant of the discussion.
    there_is_an_open_issue_created_by "My Favorite Ants", "Batiatus"
    i_log_in_as "Batiatus"
    i_go_to 'the issue page for "My Favorite Ants"'
    i_write_a_new_comment "I'll add more later."
    i_press "Post Comment"
    i_wait_for_the_success_message

    # Comment on Batiatus' issue, mention him, reply to him in a discussion he is active in.
    i_log_in_as "Archibald"
    i_go_to 'the issue page for "My Favorite Ants"'
    i_write_a_new_comment_at_batiatus_id "Great list already!"
    i_press "Post Comment"
    i_wait_for_the_success_message

    # Confirm that Batiatus was only mentioned once.
    i_log_in_as "Batiatus"
    i_go_to 'my notifications page'
    i_should_see "Archibald mentioned you in the comment on the issue My Favorite Ants"
    i_should_see_number_of_notification 1
  end

  scenario "Do not repeat notifications for any given attached/notifier combination" do
    there_is_an_open_issue_created_by "My Favorite Ants", "Batiatus"

    # Edit Batiatus' issue twice.
    i_go_to 'the issue page for "My Favorite Ants"'
    i_follow "Edit"
    i_fill_in_with_followed_by_the_user_id_of "issue_description", "Helo @user", "Batiatus"
    i_press "Save"
    i_wait_for_the_success_message

    i_follow "Edit"
    i_fill_in_with_followed_by_the_user_id_of "issue_description", "Hello @user", "Batiatus"
    i_press "Save"
    i_wait_for_the_success_message

    # Confirm that Batiatus was only mentioned once.
    i_log_in_as "Batiatus"
    i_go_to 'my notifications page'
    i_should_see "Archibald mentioned you in the issue My Favorite Ants"
    i_should_see_number_of_notification 1
  end

  scenario 'Mentioning users in "things" (issue description)' do
    # Mention Batiatus in the description of an issue.
    i_go_to 'the new issue page'
    i_fill_in "issue_title", with: "Resolve homonyms"
    i_fill_in_with_followed_by_the_user_id_of "issue_description", "@user", "Batiatus"
    i_press "Save"
    i_wait_for_the_success_message

    # Confirm Batiatus was notified.
    i_log_in_as "Batiatus"
    i_go_to 'my notifications page'
    i_should_see "Archibald mentioned you in the issue Resolve homonyms"
    i_should_see_number_of_notification 1
  end

  scenario 'Mentioning users in "things" (site notice messages)' do
    # Mention Batiatus in the message of a site notice.
    i_go_to 'the site notices page'
    i_follow "New"
    i_fill_in "site_notice_title", with: "New AntCat features"
    i_fill_in_with_followed_by_the_user_id_of "site_notice_message", "@user", "Batiatus"
    i_press "Publish"
    i_wait_for_the_success_message

    # Confirm Batiatus was notified.
    i_log_in_as "Batiatus"
    i_go_to 'my notifications page'
    i_should_see "Archibald mentioned you in the site notice New AntCat features"
    i_should_see_number_of_notification 1
  end
end

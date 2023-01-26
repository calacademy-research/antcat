# frozen_string_literal: true

require 'rails_helper'

feature "Site notices" do
  background do
    i_log_in_as_a_catalog_editor_named "Batiatus"
  end

  scenario "Adding a site notice (with feed)" do
    i_go_to 'the site notices page'
    i_follow "New"
    i_fill_in "site_notice_title", with: "New AntCat features"
    i_fill_in "site_notice_message", with: "You would not believe it!"
    i_press "Publish"
    i_should_see "Successfully created site notice"
    i_should_see "Added by Batiatus"
  end

  scenario "Reading a notice marks it as read" do
    there_is_a_site_notice_i_havent_read_yet "A Site Notice"

    i_go_to 'the users page'
    i_should_see_an_unread_site_notice

    i_follow "new notice!", within: 'the desktop menu'
    i_follow "A Site Notice"
    i_should_see "A Site Notice"
    i_should_not_see_any_unread_site_notices
  end

  scenario "Mark all as read from the site notices page" do
    there_is_a_site_notice_i_havent_read_yet "A Site Notice"

    i_go_to 'the site notices page'
    i_should_see_an_unread_site_notice

    i_follow "Mark all as read"
    i_should_see "All site notices successfully marked as read."
    i_should_not_see_any_unread_site_notices
    i_should_not_see "Mark all as read"
  end
end

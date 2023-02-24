# frozen_string_literal: true

require 'rails_helper'

feature "Site notices", as: :editor do
  def there_is_a_site_notice_i_havent_read_yet title
    sleep 1 # To please the `unread` gem which uses timestamps.
    create :site_notice, title: title
  end

  scenario "Adding a site notice" do
    visit site_notices_path
    i_follow "New"
    fill_in "site_notice_title", with: "New AntCat features"
    fill_in "site_notice_message", with: "You would not believe it!"
    click_button "Publish"
    i_should_see "Successfully created site notice"
  end

  scenario "Reading a notice marks it as read" do
    there_is_a_site_notice_i_havent_read_yet "A Site Notice"

    i_go_to 'the users page'
    i_should_see "new notice"

    i_follow "new notice!", within: 'the desktop menu'
    i_follow "A Site Notice"
    i_should_see "A Site Notice"
    i_should_not_see "new notice"
  end

  scenario "Mark all as read from the site notices page" do
    there_is_a_site_notice_i_havent_read_yet "A Site Notice"

    visit site_notices_path
    i_should_see "new notice"

    i_follow "Mark all as read"
    i_should_see "All site notices successfully marked as read."
    i_should_not_see "new notice"
    i_should_not_see "Mark all as read"
  end
end

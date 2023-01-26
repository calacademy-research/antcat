# frozen_string_literal: true

require 'rails_helper'

feature "Activity feed" do
  scenario "Filtering activities by event" do
    there_is_a_journal_activity_by "destroy", "Batiatus"
    there_is_a_journal_activity_by "update", "Batiatus"

    i_go_to 'the activity feed'
    i_should_see_number_of_items_in_the_activity_feed 2

    i_select "Destroy", from: "event"
    i_press "Filter"
    i_should_see_number_of_items_in_the_activity_feed 1
    i_should_see "Batiatus deleted the journal", within: 'the activity feed'
  end

  scenario "Showing/hiding automated edits" do
    there_is_an_activity_with_the_edit_summary "Not automated"
    there_is_an_automated_activity_with_the_edit_summary "Automated edit"

    i_go_to 'the activity feed'
    i_should_see "Not automated"
    i_should_not_see "Automated edit"

    i_check "show_automated_edits"
    i_press "Filter"
    i_should_see "Not automated"
    i_should_see "Automated edit"
  end

  scenario "Pagination with quirks" do
    i_log_in_as_a_developer
    activities_are_paginated_with_per_page 2
    there_are_number_of_activity_items 5

    # Using pagination as usual.
    i_go_to 'the activity feed'
    i_should_see_number_of_items_in_the_activity_feed 2
    the_query_string_should_not_contain "page="
    i_follow "3"
    the_query_string_should_contain "page=3"

    # Deleting an activity items = return to the same page.
    i_follow "2"
    i_follow_the_first "Delete"
    i_should_see "was successfully deleted"
    the_query_string_should_contain "page=2"

    # Restore for future tests.
    activities_are_paginated_with_per_page 30
  end

  scenario "Pagination with filtering quirks" do
    activities_are_paginated_with_per_page 2
    there_is_an_automated_activity_with_the_edit_summary "[1] fix URL by script"
    there_is_an_automated_activity_with_the_edit_summary "[2] fix URL by script"
    there_is_an_activity_with_the_edit_summary "[3] updated pagination"
    there_is_an_activity_with_the_edit_summary "[4] updated pagination"
    there_is_an_activity_with_the_edit_summary "[5] updated pagination"
    there_is_an_activity_with_the_edit_summary "[6] updated pagination"
    there_is_an_automated_activity_with_the_edit_summary "[7] fix URL by script"
    there_is_an_automated_activity_with_the_edit_summary "[8] fix URL by script"

    i_go_to 'the activity feed'
    i_should_see_number_of_items_in_the_activity_feed 2
    i_should_see "[6] updated pagination"
    i_should_see "[5] updated pagination"

    i_follow "2"
    i_should_see_number_of_items_in_the_activity_feed 2
    i_should_see "[4] updated pagination"
    i_should_see "[3] updated pagination"

    i_follow_the_first "Link"
    i_should_see_number_of_items_in_the_activity_feed 2
    i_should_see "[4] updated pagination"
    i_should_see "[3] updated pagination"

    activities_are_paginated_with_per_page 30
  end
end

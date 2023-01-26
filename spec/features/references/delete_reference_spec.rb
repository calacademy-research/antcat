# frozen_string_literal: true

require 'rails_helper'

feature "Delete reference" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Delete a reference (with feed)" do
    this_reference_exists author: "Fisher", year: 2004

    i_go_to 'the page of the most recent reference'
    i_follow "Delete"
    i_should_see "Reference was successfully deleted"

    i_go_to 'the activity feed'
    i_should_see "Archibald deleted the reference Fisher, 2004", within: 'the activity feed'
  end

  scenario "Try to delete a reference when there are references to it" do
    there_is_a_reference_referenced_in_a_history_item

    i_go_to 'the page of the oldest reference'
    i_will_confirm_on_the_next_step
    i_follow "Delete"
    i_should_see "Other records refer to this reference, so it can't be deleted."
  end
end

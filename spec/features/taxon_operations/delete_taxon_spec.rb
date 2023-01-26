# frozen_string_literal: true

require 'rails_helper'

feature "Deleting a taxon" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Deleted taxon (with feed)" do
    # Create Formicidae to make sure the deleted taxon has a parent.
    the_formicidae_family_exists
    there_is_a_subfamily "Antcatinae"

    i_go_to 'the catalog page for "Antcatinae"'
    i_will_confirm_on_the_next_step
    i_follow "Delete"
    i_should_see "Taxon was successfully deleted."

    i_go_to 'the activity feed'
    i_should_see "Archibald deleted the subfamily Antcatinae", within: 'the activity feed'
  end

  scenario "If taxon has only references from others taxt, still show the Delete button, but allow deleting" do
    there_is_a_genus "Atta"
    there_is_a_genus "Eciton"
    there_is_a_reference_section_for_that_includes_a_tag_for "Eciton", "Atta"

    i_go_to 'the catalog page for "Atta"'
    i_will_confirm_on_the_next_step
    i_follow "Delete"
    i_should_see "Other records refer to this taxon, so it can't be deleted. "
    i_should_not_see "Taxon was successfully deleted"
  end
end

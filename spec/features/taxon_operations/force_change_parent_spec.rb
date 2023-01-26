# frozen_string_literal: true

require 'rails_helper'

feature "Force-changing parent" do
  background do
    i_log_in_as_a_superadmin_named "Archibald"
  end

  scenario "Changing a genus's subfamily (with feed)" do
    the_formicidae_family_exists
    there_is_a_subfamily "Attininae"
    there_is_a_genus_in_the_subfamily "Atta", "Attininae"
    there_is_a_subfamily "Ecitoninae"

    i_go_to 'the catalog page for "Atta"'
    i_follow "Force parent change"
    i_pick_from_the_taxon_picker "Ecitoninae", "#new_parent_id"
    i_press "Change parent"
    i_should_be_on 'the catalog page for "Atta"'
    the_association_of_taxon_should_be "subfamily", "Atta", "Ecitoninae"

    i_go_to 'the activity feed'
    i_should_see "Archibald force-changed the parent of Atta", within: 'the activity feed'
  end
end

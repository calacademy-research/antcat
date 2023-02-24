# frozen_string_literal: true

require 'rails_helper'

feature "Delete reference" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Delete a reference (with feed)" do
    reference = create :any_reference, author_string: "Fisher", year: 2004

    visit reference_path(reference)
    i_follow "Delete"
    i_should_see "Reference was successfully deleted"

    there_should_be_an_activity "Archibald deleted the reference Fisher, 2004"
  end

  scenario "Try to delete a reference when there are references to it" do
    reference = create :any_reference
    create :history_item, :taxt, taxt: Taxt.ref(reference.id)

    i_go_to 'the page of the oldest reference'
    i_will_confirm_on_the_next_step
    i_follow "Delete"
    i_should_see "Other records refer to this reference, so it can't be deleted."
  end
end

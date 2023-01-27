# frozen_string_literal: true

require 'rails_helper'

feature "Merging authors", %(
As an editor of AntCat
I want to merge together author names
So that they are correct
) do
  background do
    i_log_in_as_a_catalog_editor
    create :any_reference, author_string: 'Bolton, B.', title: 'Annals of Ants'
    create :any_reference, author_string: 'Bolton, Ba.', title: 'More ants'
  end

  scenario "Merging two authors" do
    i_go_to 'the author page for "Bolton, B."'
    i_should_see "Bolton, B."
    i_should_not_see "Bolton, Ba."

    i_follow "Merge"
    i_set_author_to_merge_id_to_the_id_of "Bolton, Ba."
    click_button "Next"
    i_should_see "Annals of Ants"
    i_should_see "More ants"

    click_button "Merge these authors"
    i_should_see "Probably merged authors"
    i_should_be_on 'the author page for "Bolton, B."'
    i_should_see "Bolton, Ba."
    i_should_see "Bolton, B."
  end

  scenario "Searching for an author that isn't found" do
    i_go_to 'the author page for "Bolton, B."'
    i_follow "Merge"
    fill_in "author_to_merge_name", with: "asdf"
    click_button "Next"
    i_should_see "Author to merge must be specified"
  end
end

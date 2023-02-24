# frozen_string_literal: true

require 'rails_helper'

feature "Merging authors", as: :editor do
  background do
    create :any_reference, author_string: 'Bolton, B.', title: 'Annals of Ants'
    create :any_reference, author_string: 'Bolton, Ba.', title: 'More ants'
  end

  scenario "Merging two authors" do
    author = AuthorName.find_by!(name: "Bolton, B.").author

    visit author_path(author)
    i_should_see "Bolton, B."
    i_should_not_see "Bolton, Ba."

    i_follow "Merge"
    author = AuthorName.find_by!(name: "Bolton, Ba.").author
    find('#author_to_merge_id', visible: false).set(author.id) # HACK: For when JavaScript is disabled.
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
    author = AuthorName.find_by!(name: "Bolton, B.").author

    visit author_path(author)
    i_follow "Merge"
    fill_in "author_to_merge_name", with: "asdf"
    click_button "Next"
    i_should_see "Author to merge must be specified"
  end
end

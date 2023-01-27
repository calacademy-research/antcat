# frozen_string_literal: true

require 'rails_helper'

feature "Working with authors and their names" do
  def the_following_names_exist_for_an_author *author_name_strings
    author = create :author
    Array.wrap(author_name_strings).each do |author_name_string|
      author.names.create!(name: author_name_string)
    end
  end

  scenario "Seeing references by author (going to the author's page)" do
    create :any_reference, author_string: 'Bolton, B.', title: 'Cool Ants'

    i_go_to "the page of the most recent reference"
    i_follow_the_first "Bolton, B."
    i_should_see "References by Bolton, B."
    i_should_see "Cool Ants"
  end

  scenario "Seeing all the authors with their names" do
    the_following_names_exist_for_an_author "Bolton, B.", "Bolton, Ba."
    the_following_names_exist_for_an_author "Fisher, B."

    i_go_to "the authors page"
    i_should_see "Bolton, B.; Bolton, Ba."
    i_should_see "Fisher, B."
  end

  scenario "Adding an alternative spelling of an author name", as: :editor do
    the_following_names_exist_for_an_author "Bolton, B."

    i_go_to 'the author page for "Bolton, B."'
    i_follow "Add alternative spelling"
    fill_in "author_name_name", with: "Fisher, B."
    click_button "Save"
    i_should_see "Author name was successfully created"

    i_follow "Authors", within: "the breadcrumbs"
    i_should_see "Bolton, B.; Fisher, B."
  end

  scenario "Entering an existing author name", as: :editor do
    the_following_names_exist_for_an_author "Bolton, B."

    i_go_to 'the author page for "Bolton, B."'
    i_follow "Add alternative spelling"
    fill_in "author_name_name", with: "Bolton, B."
    click_button "Save"
    i_should_see "Name has already been taken"
  end

  scenario "Updating an existing author name", as: :editor do
    the_following_names_exist_for_an_author "Bolton, B."

    i_go_to 'the author page for "Bolton, B."'
    i_follow "Edit"
    fill_in "author_name_name", with: "Bolton, Z."
    click_button "Save"
    i_should_see "Author name was successfully updated"

    i_follow "Authors", within: "the breadcrumbs"
    i_should_see "Bolton, Z."
    i_should_not_see "Bolton, B."
  end
end

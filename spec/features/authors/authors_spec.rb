# frozen_string_literal: true

require 'rails_helper'

feature "Authors" do
  def the_following_names_exist_for_an_author *author_name_strings
    author = create :author
    Array.wrap(author_name_strings).each do |author_name_string|
      author.names.create!(name: author_name_string)
    end
    author
  end

  scenario "Seeing all the authors with their names", as: :visitor do
    the_following_names_exist_for_an_author "Bolton, B.", "Bolton, Ba."
    the_following_names_exist_for_an_author "Fisher, B."

    visit authors_path
    i_should_see "Bolton, B.; Bolton, Ba."
    i_should_see "Fisher, B."
  end

  scenario "Adding an alternative spelling of an author name", as: :editor do
    author = the_following_names_exist_for_an_author "Bolton, B."

    visit author_path(author)
    i_follow "Add alternative spelling"
    fill_in "author_name_name", with: "Fisher, B."
    click_button "Save"
    i_should_see "Author name was successfully created"

    i_follow "Authors", within_scope: "#breadcrumbs"
    i_should_see "Bolton, B.; Fisher, B."
  end

  scenario "Entering an existing author name", as: :editor do
    author = the_following_names_exist_for_an_author "Bolton, B."

    visit author_path(author)
    i_follow "Add alternative spelling"
    fill_in "author_name_name", with: "Bolton, B."
    click_button "Save"
    i_should_see "Name has already been taken"
  end

  scenario "Updating an existing author name", as: :editor do
    author = the_following_names_exist_for_an_author "Bolton, B."

    visit author_path(author)
    i_follow "Edit"
    fill_in "author_name_name", with: "Bolton, Z."
    click_button "Save"
    i_should_see "Author name was successfully updated"

    i_follow "Authors", within_scope: "#breadcrumbs"
    i_should_see "Bolton, Z."
    i_should_not_see "Bolton, B."
  end
end

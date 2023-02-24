# frozen_string_literal: true

require 'rails_helper'

feature "Add reference unsuccessfully", as: :helper do
  background do
    visit new_reference_path
  end

  scenario "Leaving required fields blank (general fields)" do
    fill_in "reference_author_names_string", with: ""
    fill_in "reference_title", with: ""
    fill_in "reference_year", with: ""
    fill_in "reference_pagination", with: ""
    click_button "Save"
    i_should_see "Author names can't be blank"
    i_should_see "Title can't be blank"
    i_should_see "Year can't be blank"
    i_should_see "Pagination can't be blank"
  end

  scenario "Leaving required fields blank (`ArticleReference`)" do
    fill_in "reference_journal_name", with: ""
    fill_in "reference_series_volume_issue", with: ""
    click_button "Save"
    i_should_see "Journal: Name can't be blank"
    i_should_see "Series volume issue can't be blank"
  end

  scenario "Leaving required fields blank (`BookReference`)" do
    i_select_the_reference_tab "#book-tab"
    fill_in "reference_publisher_string", with: ""
    click_button "Save"
    i_should_see "Publisher string couldn't be parsed"
  end

  scenario "Leaving a required field blank should not affect other fields (`ArticleReference`)" do
    fill_in "reference_title", with: "A reference title"
    fill_in "reference_journal_name", with: "Ant Journal"
    fill_in "reference_pagination", with: "2"
    click_button "Save"
    i_should_see "Year can't be blank"
    the_field_should_contain "reference_title", "A reference title"

    i_select_the_reference_tab "#article-tab"
    the_field_should_contain "reference_journal_name", "Ant Journal"
    the_field_should_contain "reference_pagination", "2"
  end

  scenario "Leaving a required field blank should not affect other fields (`BookReference`)" do
    i_select_the_reference_tab "#book-tab"
    fill_in "reference_title", with: "A reference title"
    fill_in "reference_publisher_string", with: "Capua: House of Batiatus"
    fill_in "reference_pagination", with: "2"
    click_button "Save"
    the_field_should_contain "reference_title", "A reference title"

    i_select_the_reference_tab "#book-tab"
    the_field_should_contain "reference_publisher_string", "Capua: House of Batiatus"
    the_field_should_contain "reference_pagination", "2"
  end

  scenario "Invalid author name (and maintain already filled in fields and correcting)" do
    fill_in "reference_author_names_string", with: "Bolton, B., Pizza; Fisher, B.; "
    click_button "Save"
    i_should_see "Author names (Bolton, B., Pizza): Name can only contain a single comma"
    the_field_should_contain "reference_author_names_string", "Bolton, B., Pizza; Fisher, B.; "

    fill_in "reference_author_names_string", with: "Bolton, B.P.; Fisher, B.; "
    fill_in "reference_title", with: "A reference title"
    fill_in "reference_year", with: "1981"
    fill_in "reference_journal_name", with: "Ant Journal"
    fill_in "reference_series_volume_issue", with: "1"
    fill_in "reference_pagination", with: "2"
    click_button "Save"
    i_should_see "Bolton, B.P.; Fisher, B. 1981. A reference title. Ant Journal 1:2"
  end

  scenario "Invalid author name" do
    fill_in "reference_author_names_string", with: "A"
    click_button "Save"
    i_should_see "Author names (A): Name is too short (minimum is 2 characters)"
    the_field_should_contain "reference_author_names_string", "A"
  end

  scenario "Unparsable (blank) journal name (and maintain already filled in fields)" do
    fill_in "reference_title", with: "A reference title"
    fill_in "reference_journal_name", with: ""
    fill_in "reference_pagination", with: "1"
    click_button "Save"
    i_should_see "Journal: Name can't be blank"
    the_field_should_contain "reference_title", "A reference title"

    i_select_the_reference_tab "#article-tab"
    the_field_should_contain "reference_journal_name", ""
    the_field_should_contain "reference_pagination", "1"
  end

  scenario "Unparsable publisher string (and maintain already filled in fields)" do
    fill_in "reference_title", with: "A reference title"
    i_select_the_reference_tab "#book-tab"
    fill_in "reference_publisher_string", with: "Pensoft, Sophia"
    fill_in "reference_pagination", with: "1"
    click_button "Save"
    i_should_see "Publisher string couldn't be parsed. Expected format 'Place: Publisher'."

    i_select_the_reference_tab "#book-tab"
    the_field_should_contain "reference_title", "A reference title"
    the_field_should_contain "reference_publisher_string", "Pensoft, Sophia"
    the_field_should_contain "reference_pagination", "1"
  end
end

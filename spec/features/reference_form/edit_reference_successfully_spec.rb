# frozen_string_literal: true

require 'rails_helper'

feature "Edit reference successfully" do
  background do
    i_log_in_as_a_helper_editor
  end

  scenario "Blanking required fields (general fields)" do
    there_is_an_article_reference

    i_go_to 'the edit page for the most recent reference'
    i_fill_in "reference_author_names_string", with: ""
    i_fill_in "reference_title", with: ""
    i_fill_in "reference_year", with: ""
    i_fill_in "reference_pagination", with: ""
    i_press "Save"
    i_should_see "Author names can't be blank"
    i_should_see "Title can't be blank"
    i_should_see "Year can't be blank"
    i_should_see "Pagination can't be blank"
  end

  scenario "Blanking required fields (`ArticleReference`)" do
    there_is_an_article_reference

    i_go_to 'the edit page for the most recent reference'
    i_fill_in "reference_journal_name", with: ""
    i_fill_in "reference_series_volume_issue", with: ""
    i_press "Save"
    i_should_see "Journal: Name can't be blank"
    i_should_see "Series volume issue can't be blank"
  end

  scenario "Blanking required fields (`BookReference`)" do
    there_is_a_book_reference

    i_go_to 'the edit page for the most recent reference'
    i_fill_in "reference_publisher_string", with: ""
    i_press "Save"
    i_should_see "Publisher string couldn't be parsed."
  end

  scenario "Change a reference's type" do
    this_article_reference_exists author: "Fisher, B.", title: "Ants", year: 2010

    i_go_to 'the edit page for the most recent reference'
    i_select_the_reference_tab "#book-tab"
    i_fill_in "reference_publisher_string", with: "New York: Wiley"
    i_fill_in "reference_pagination", with: "22 pp."
    i_press "Save"
    i_should_see "Fisher, B. 2010. Ants. New York: Wiley, 22 pp."
  end

  scenario "Edit a `NestedReference`" do
    this_article_reference_exists author: "Ward, P.S.", title: "Ants", year: 2001, journal: 'Acta', series_volume_issue: "4", pagination: "9"

    create :nested_reference,
      title: "More ants",
      author_string: "Bolton, B.",
      year: 2001,
      pagination: "In:",
      nesting_reference: Reference.last

    i_go_to 'the references page'
    i_should_see "Bolton, B. 2001. More ants. In: Ward, P.S. 2001. Ants. Acta 4:9"

    i_go_to 'the edit page for the most recent reference'
    i_fill_in "reference_pagination", with: "Pp. 32 in:"
    i_press "Save"
    i_should_see "Bolton, B. 2001. More ants. Pp. 32 in: Ward, P.S. 2001. Ants. Acta 4:9"
  end
end

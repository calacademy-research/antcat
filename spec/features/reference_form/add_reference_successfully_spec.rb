# frozen_string_literal: true

require 'rails_helper'

feature "Add reference" do
  background do
    i_log_in_as_a_helper_editor
    i_go_to 'the references page'
    i_follow "New"
  end

  scenario "Adding an `ArticleReference`" do
    i_fill_in "reference_author_names_string", with: "Ward, B.L.;Bolton, B."
    i_fill_in "reference_title", with: "A reference title"
    i_fill_in "reference_year", with: "1981"
    i_fill_in "reference_year_suffix", with: "f"
    i_fill_in "reference_bolton_key", with: "Ward, B.L. & Bolton, B., 1981a"
    i_fill_in "reference_journal_name", with: "Ant Journal"
    i_fill_in "reference_series_volume_issue", with: "1"
    i_fill_in "reference_pagination", with: "2"
    i_press "Save"
    i_should_see "Ward, B.L.; Bolton, B. 1981f. A reference title. Ant Journal 1:2"
    i_should_see "Ward B.L. Bolton B. 1981a"
  end

  scenario "Adding a `BookReference`" do
    i_fill_in "reference_author_names_string", with: "Ward, B.L.;Bolton, B."
    i_fill_in "reference_title", with: "A reference title"
    i_fill_in "reference_year", with: "1981"
    i_select_the_reference_tab "#book-tab"
    i_fill_in "reference_publisher_string", with: "New York: Houghton Mifflin"
    i_fill_in "reference_pagination", with: "32 pp."
    i_press "Save"
    i_should_see "Ward, B.L.; Bolton, B. 1981. A reference title. New York: Houghton Mifflin, 32 pp."
  end

  scenario "Adding a `NestedReference`" do
    this_article_reference_exists author: "Ward, P.S.", title: "Ants Nests", year: 2010, journal: 'Acta', series_volume_issue: "4", pagination: "9"

    i_fill_in "reference_author_names_string", with: "Ward, B.L.;Bolton, B."
    i_fill_in "reference_title", with: "A reference title"
    i_fill_in "reference_year", with: "1981"
    i_select_the_reference_tab "#nested-tab"
    i_fill_in "reference_pagination", with: "Pp. 32-33 in:"
    i_fill_in_reference_nesting_reference_id_with_the_id_for "Ants Nests"
    i_press "Save"
    i_should_see "Ward, B.L.; Bolton, B. 1981. A reference title. Pp. 32-33 in: Ward, P.S. 2010. Ants Nests. Acta 4:9"
  end
end

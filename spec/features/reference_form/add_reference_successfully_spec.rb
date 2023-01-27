# frozen_string_literal: true

require 'rails_helper'

feature "Add reference", as: :helper do
  background do
    i_go_to 'the references page'
    i_follow "New"
  end

  scenario "Adding an `ArticleReference`" do
    fill_in "reference_author_names_string", with: "Ward, B.L.;Bolton, B."
    fill_in "reference_title", with: "A reference title"
    fill_in "reference_year", with: "1981"
    fill_in "reference_year_suffix", with: "f"
    fill_in "reference_bolton_key", with: "Ward, B.L. & Bolton, B., 1981a"
    fill_in "reference_journal_name", with: "Ant Journal"
    fill_in "reference_series_volume_issue", with: "1"
    fill_in "reference_pagination", with: "2"
    click_button "Save"
    i_should_see "Ward, B.L.; Bolton, B. 1981f. A reference title. Ant Journal 1:2"
    i_should_see "Ward B.L. Bolton B. 1981a"
  end

  scenario "Adding a `BookReference`" do
    fill_in "reference_author_names_string", with: "Ward, B.L.;Bolton, B."
    fill_in "reference_title", with: "A reference title"
    fill_in "reference_year", with: "1981"
    i_select_the_reference_tab "#book-tab"
    fill_in "reference_publisher_string", with: "New York: Houghton Mifflin"
    fill_in "reference_pagination", with: "32 pp."
    click_button "Save"
    i_should_see "Ward, B.L.; Bolton, B. 1981. A reference title. New York: Houghton Mifflin, 32 pp."
  end

  scenario "Adding a `NestedReference`" do
    nesting_reference = create :article_reference, author_string: "Ward, P.S.", title: "Ants Nests", year: 2010,
      journal: create(:journal, name: 'Acta'), series_volume_issue: "4", pagination: "9"

    fill_in "reference_author_names_string", with: "Ward, B.L.;Bolton, B."
    fill_in "reference_title", with: "A reference title"
    fill_in "reference_year", with: "1981"
    i_select_the_reference_tab "#nested-tab"
    fill_in "reference_pagination", with: "Pp. 32-33 in:"
    fill_in "reference_nesting_reference_id", with: nesting_reference.id
    click_button "Save"
    i_should_see "Ward, B.L.; Bolton, B. 1981. A reference title. Pp. 32-33 in: Ward, P.S. 2010. Ants Nests. Acta 4:9"
  end
end

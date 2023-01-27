# frozen_string_literal: true

require 'rails_helper'

feature "Edit reference successfully", as: :helper do
  scenario "Blanking required fields (general fields)" do
    create :article_reference, :with_author_name

    i_go_to 'the edit page for the most recent reference'
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

  scenario "Blanking required fields (`ArticleReference`)" do
    create :article_reference, :with_author_name

    i_go_to 'the edit page for the most recent reference'
    fill_in "reference_journal_name", with: ""
    fill_in "reference_series_volume_issue", with: ""
    click_button "Save"
    i_should_see "Journal: Name can't be blank"
    i_should_see "Series volume issue can't be blank"
  end

  scenario "Blanking required fields (`BookReference`)" do
    create :book_reference, :with_author_name

    i_go_to 'the edit page for the most recent reference'
    fill_in "reference_publisher_string", with: ""
    click_button "Save"
    i_should_see "Publisher string couldn't be parsed."
  end

  scenario "Change a reference's type" do
    create :article_reference, author_string: "Fisher, B.", title: "Ants", year: 2010

    i_go_to 'the edit page for the most recent reference'
    i_select_the_reference_tab "#book-tab"
    fill_in "reference_publisher_string", with: "New York: Wiley"
    fill_in "reference_pagination", with: "22 pp."
    click_button "Save"
    i_should_see "Fisher, B. 2010. Ants. New York: Wiley, 22 pp."
  end

  scenario "Edit a `NestedReference`" do
    create :article_reference, author_string: "Ward, P.S.", title: "Ants", year: 2001,
      journal: create(:journal, name: 'Acta'), series_volume_issue: "4", pagination: "9"

    create :nested_reference,
      title: "More ants",
      author_string: "Bolton, B.",
      year: 2001,
      pagination: "In:",
      nesting_reference: Reference.last

    i_go_to 'the references page'
    i_should_see "Bolton, B. 2001. More ants. In: Ward, P.S. 2001. Ants. Acta 4:9"

    i_go_to 'the edit page for the most recent reference'
    fill_in "reference_pagination", with: "Pp. 32 in:"
    click_button "Save"
    i_should_see "Bolton, B. 2001. More ants. Pp. 32 in: Ward, P.S. 2001. Ants. Acta 4:9"
  end
end

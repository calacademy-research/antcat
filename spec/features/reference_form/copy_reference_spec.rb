# frozen_string_literal: true

require 'rails_helper'

feature "Copy reference", as: :helper do
  scenario "Copy an `ArticleReference`" do
    reference = create :article_reference, author_string: "Ward, P.S.", title: "Ants", year: 1910, year_suffix: "b", stated_year: "1911",
      journal: create(:journal, name: 'Acta'), series_volume_issue: "4", pagination: "9"

    visit reference_path(reference)
    i_follow "Copy"
    the_field_should_contain "reference_author_names_string", "Ward, P.S."
    the_field_should_contain "reference_title", "Ants"
    the_field_should_contain "reference_year", "1910"
    the_field_should_contain "reference_year_suffix", "b"
    the_field_should_contain "reference_stated_year", "1911"
    the_field_should_contain "reference_pagination", "9"
    the_field_should_contain "reference_journal_name", "Acta"
    the_field_should_contain "reference_series_volume_issue", "4"
  end
end

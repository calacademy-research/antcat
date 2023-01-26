# frozen_string_literal: true

require 'rails_helper'

feature "Reference sections" do
  background do
    i_am_logged_in
  end

  scenario "Filtering reference sections by search query" do
    there_is_a_reference_section_with_the_references_taxt "typo of Forel"
    there_is_a_reference_section_with_the_references_taxt "typo of August"

    i_go_to 'the reference sections page'
    i_should_see "typo of Forel"
    i_should_see "typo of August"

    i_fill_in "q", with: "Forel"
    i_press "Search"
    i_should_see "typo of Forel"
    i_should_not_see "typo of August"

    i_fill_in "q", with: "asdasdasd"
    i_press "Search"
    i_should_not_see "typo of Forel"
    i_should_not_see "typo of August"
  end
end

# frozen_string_literal: true

require 'rails_helper'

feature "History items" do
  background do
    i_am_logged_in
  end

  scenario "Filtering history items by search query" do
    there_is_a_history_item "typo of Forel"
    there_is_a_history_item "typo of August"

    i_go_to 'the history items page'
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

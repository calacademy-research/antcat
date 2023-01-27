# frozen_string_literal: true

require 'rails_helper'

feature "History items" do
  background do
    i_am_logged_in
  end

  scenario "Filtering history items by search query" do
    create :history_item, :taxt, taxt: "typo of Forel"
    create :history_item, :taxt, taxt: "typo of August"

    i_go_to 'the history items page'
    i_should_see "typo of Forel"
    i_should_see "typo of August"

    fill_in "q", with: "Forel"
    click_button "Search"
    i_should_see "typo of Forel"
    i_should_not_see "typo of August"

    fill_in "q", with: "asdasdasd"
    click_button "Search"
    i_should_not_see "typo of Forel"
    i_should_not_see "typo of August"
  end
end

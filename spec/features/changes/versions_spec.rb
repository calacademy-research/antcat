# frozen_string_literal: true

require 'rails_helper'

feature "Versions (filtering)", :versioning do
  background do
    i_log_in_as_a_catalog_editor
  end

  scenario "Filtering versions by event" do
    create :journal, name: "Psyche"
    i_go_to 'the references page'
    i_follow "Journals"
    i_follow "Psyche"
    i_follow "Delete"

    i_go_to 'the versions page'
    i_should_see_number_of_versions 3

    select "destroy", from: "event"
    click_button "Filter"
    i_should_see_number_of_versions 1

    i_follow "Clear"
    i_should_see_number_of_versions 3
  end

  scenario "Scenario: Filtering versions by search query" do
    create :journal, name: "Psyche"

    i_go_to 'the versions page'
    i_should_see_number_of_versions 1

    fill_in "q", with: "Psyche"
    click_button "Filter"
    i_should_see_number_of_versions 1

    fill_in "q", with: "asdasdasd"
    click_button "Filter"
    i_should_see_number_of_versions 0
  end
end

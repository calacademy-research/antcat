# frozen_string_literal: true

require 'rails_helper'

feature "Versions (filtering)", :versioning do
  background do
    i_log_in_as_a_catalog_editor
  end

  scenario "Filtering versions by event" do
    a_journal_exists_with_a_name_of "Psyche"
    i_go_to 'the references page'
    i_follow "Journals"
    i_follow "Psyche"
    i_follow "Delete"

    i_go_to 'the versions page'
    i_should_see_number_of_versions 3

    i_select "destroy", from: "event"
    i_press "Filter"
    i_should_see_number_of_versions 1

    i_follow "Clear"
    i_should_see_number_of_versions 3
  end

  scenario "Scenario: Filtering versions by search query" do
    a_journal_exists_with_a_name_of "Psyche"

    i_go_to 'the versions page'
    i_should_see_number_of_versions 1

    i_fill_in "q", with: "Psyche"
    i_press "Filter"
    i_should_see_number_of_versions 1

    i_fill_in "q", with: "asdasdasd"
    i_press "Filter"
    i_should_see_number_of_versions 0
  end
end

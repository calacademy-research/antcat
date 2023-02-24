# frozen_string_literal: true

require 'rails_helper'

feature "Versions (filtering)", as: :editor, versioning: true do
  def i_should_see_number_of_versions count
    all "table tbody tr", count: count
  end

  scenario "Filtering versions by event" do
    create :journal, name: "Psyche"
    visit references_path
    i_follow "Journals"
    i_follow "Psyche"
    i_follow "Delete"

    visit versions_path
    i_should_see_number_of_versions 3

    select "destroy", from: "event"
    click_button "Filter"
    i_should_see_number_of_versions 1

    i_follow "Clear"
    i_should_see_number_of_versions 3
  end

  scenario "Scenario: Filtering versions by search query" do
    create :journal, name: "Psyche"

    visit versions_path
    i_should_see_number_of_versions 1

    fill_in "q", with: "Psyche"
    click_button "Filter"
    i_should_see_number_of_versions 1

    fill_in "q", with: "asdasdasd"
    click_button "Filter"
    i_should_see_number_of_versions 0
  end
end

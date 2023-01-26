# frozen_string_literal: true

require 'rails_helper'

feature "Latest Additions", %(
  As an editor of AntCat
  I want to see recently added references
  So I can keep up with the state of the literature
) do
  background do
    there_is_a_reference
    i_log_in_as_a_catalog_editor
    i_go_to 'the latest reference additions page'
  end

  scenario "Start reviewing" do
    i_should_not_see "Being reviewed"

    i_follow "Start reviewing"
    i_should_see "Being reviewed"
  end

  scenario "Stop reviewing" do
    i_should_not_see "Reviewed"

    i_follow "Start reviewing"
    i_follow "Finish reviewing"
    i_should_see "Reviewed"
  end

  scenario "Restart reviewing" do
    i_should_not_see "Being reviewed"

    i_follow "Start reviewing"
    i_follow "Finish reviewing"
    i_follow "Restart reviewing"
    i_should_see "Being reviewed"
  end
end

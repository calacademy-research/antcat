# frozen_string_literal: true

require 'rails_helper'

feature "Editing a taxon with authorization constraints" do
  scenario "Trying to edit without being logged in" do
    there_is_a_genus "Calyptites"

    i_go_to 'the edit page for "Calyptites"'
    i_should_be_on 'the login page'
  end
end

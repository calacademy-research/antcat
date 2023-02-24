# frozen_string_literal: true

require 'rails_helper'

feature "Editing a taxon with authorization constraints" do
  scenario "Trying to edit without being logged in", as: :visitor do
    taxon = create :genus

    visit edit_taxon_path(taxon)
    i_should_be_on 'the login page'
  end
end

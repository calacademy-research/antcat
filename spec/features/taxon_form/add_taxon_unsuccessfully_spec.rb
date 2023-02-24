# frozen_string_literal: true

require 'rails_helper'

feature "Adding a taxon unsuccessfully", as: :editor do
  scenario "Having an errors, and maintain entered fields" do
    taxon = create :subfamily

    visit catalog_path(taxon)
    i_follow "Add genus"
    fill_in "taxon_name_string", with: "Atta prolasius"
    select "homonym", from: "taxon_status"
    click_button "Save"
    i_should_see "Homonym replaced by must be set for homonyms"
    i_should_see "Rank (`Genus`) and name type (`SpeciesName`) must match."
    i_should_see "Protonym: Name can't be blank"
    i_should_see "Protonym: Authorship: Reference must exist"
    i_should_see "Protonym: Authorship: Pages can't be blank"
    the_field_should_contain "taxon_name_string", "Atta prolasius"
  end

  scenario "Unparsable names, and maintain entered fields" do
    taxon = create :subfamily

    visit catalog_path(taxon)
    i_follow "Add genus"
    fill_in "taxon_name_string", with: "Invalid a b c d e f taxon name"
    fill_in "protonym_name_string", with: "Invalid a b c d e f protonym name"
    click_button "Save"
    i_should_see "Name: Could not parse name Invalid a b c d e f taxon name"
    i_should_see "Protonym: Protonym name: Could not parse name Invalid a b c d e f protonym name"
    the_field_should_contain "taxon_name_string", "Invalid a b c d e f taxon name"
    the_field_should_contain "protonym_name_string", "Invalid a b c d e f protonym name"
  end
end

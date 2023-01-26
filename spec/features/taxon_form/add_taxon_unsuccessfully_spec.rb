# frozen_string_literal: true

require 'rails_helper'

feature "Adding a taxon unsuccessfully" do
  background do
    i_log_in_as_a_catalog_editor
    there_is_a_subfamily "Formicinae"
  end

  scenario "Having an errors, and maintain entered fields" do
    i_go_to 'the catalog page for "Formicinae"'
    i_follow "Add genus"
    i_set_the_name_to "Atta prolasius"
    i_select "homonym", from: "taxon_status"
    i_press "Save"
    i_should_see "Homonym replaced by must be set for homonyms"
    i_should_see "Rank (`Genus`) and name type (`SpeciesName`) must match."
    i_should_see "Protonym: Name can't be blank"
    i_should_see "Protonym: Authorship: Reference must exist"
    i_should_see "Protonym: Authorship: Pages can't be blank"
    the_field_should_contain "taxon_name_string", "Atta prolasius"
  end

  scenario "Unparsable names, and maintain entered fields" do
    i_go_to 'the catalog page for "Formicinae"'
    i_follow "Add genus"
    i_set_the_name_to "Invalid a b c d e f taxon name"
    i_set_the_protonym_name_to "Invalid a b c d e f protonym name"
    i_press "Save"
    i_should_see "Name: Could not parse name Invalid a b c d e f taxon name"
    i_should_see "Protonym: Protonym name: Could not parse name Invalid a b c d e f protonym name"
    the_field_should_contain "taxon_name_string", "Invalid a b c d e f taxon name"
    the_field_should_contain "protonym_name_string", "Invalid a b c d e f protonym name"
  end
end

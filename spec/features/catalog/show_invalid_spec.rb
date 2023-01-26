# frozen_string_literal: true

require 'rails_helper'

feature "Showing/hiding invalid taxa", %(
  As a user of AntCat
  I want choose whether or not to take up screen space with invalid taxa
  So I can see more useful information
) do
  background do
    the_formicidae_family_exists
    there_is_a_subfamily "Availableinae"
    there_is_an_invalid_subfamily_ivalidinae
  end

  scenario "Invalid taxa are initially hidden" do
    i_go_to 'the catalog'
    i_should_see "Availableinae"
    i_should_not_see "Invalidinae"
  end

  scenario "Showing invalid taxa" do
    i_go_to 'the catalog'
    i_follow "show invalid"
    i_should_see "Invalidinae"
    i_should_see "Availableinae"

    i_follow "show valid only"
    i_should_see "Availableinae"
    i_should_not_see "Invalidinae"
  end
end

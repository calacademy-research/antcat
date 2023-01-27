# frozen_string_literal: true

require 'rails_helper'

feature "Showing/hiding invalid taxa", %(
  As a user of AntCat
  I want choose whether or not to take up screen space with invalid taxa
  So I can see more useful information
) do
  background do
    create :family, :formicidae
    create :subfamily, name_string: "Availableinae"
    create :subfamily, :unidentifiable, name_string: "Invalidinae"
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

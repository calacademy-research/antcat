# frozen_string_literal: true

require 'rails_helper'

feature "Citations" do
  scenario "Showing citations used on a catalog page" do
    there_is_a_genus_lasius_described_in_systema_piezatorum

    i_go_to 'the catalog page for "Lasius"'

    i_should_see "Systema Piezatorum", within: 'the citations section'
  end
end

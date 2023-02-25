# frozen_string_literal: true

require 'rails_helper'

feature "Force-changing parent", as: :superadmin do
  scenario "Changing a genus's subfamily (with feed)" do
    create :family, :formicidae
    subfamily = create :subfamily, name_string: "Attininae"
    taxon = create :genus, name_string: "Atta", subfamily: subfamily, tribe: nil
    new_subfamily_parent = create :subfamily, name_string: "Ecitoninae"

    visit catalog_path(taxon)
    i_follow "Force parent change"
    i_pick_from_the_taxon_picker "Ecitoninae", "#new_parent_id"
    click_button "Change parent"

    atta = Taxon.find_by!(name_cache: "Atta")
    expect(atta.subfamily).to eq new_subfamily_parent
    i_should_be_on catalog_path(taxon)

    there_should_be_an_activity "Archibald force-changed the parent of Atta"
  end
end

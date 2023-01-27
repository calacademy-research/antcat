# frozen_string_literal: true

require 'rails_helper'

feature "Citations" do
  def there_is_a_genus_lasius_described_in_systema_piezatorum
    genus = create :genus, name_string: 'Lasius'

    reference = create :any_reference, title: 'Systema Piezatorum'
    genus.protonym.authorship.update!(reference: reference)
  end

  scenario "Showing citations used on a catalog page" do
    there_is_a_genus_lasius_described_in_systema_piezatorum

    i_go_to 'the catalog page for "Lasius"'

    i_should_see "Systema Piezatorum", within: 'the citations section'
  end
end

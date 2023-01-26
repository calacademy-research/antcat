# frozen_string_literal: true

# Taxon browser.
def should_be_selected_in_the_taxon_browser name
  within '#taxon-browser-new' do
    expect(page).to have_css ".selected", text: name
  end
end

# TODO: Remove hack with 'i_select_the_taxon_browser_tab ".taxon-browser-tab-0"'.
def i_select_the_taxon_browser_tab tab_css_selector
  find(tab_css_selector, visible: false).click
end

# Citations.
def there_is_a_genus_lasius_described_in_systema_piezatorum
  genus = create :genus, name_string: 'Lasius'

  reference = create :any_reference, title: 'Systema Piezatorum'
  genus.protonym.authorship.update!(reference: reference)
end

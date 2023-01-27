# frozen_string_literal: true

require 'rails_helper'

feature "Searching the catalog" do
  def there_is_a_species_described_in year
    reference = create :any_reference, year: year
    taxon = create :species
    taxon.protonym.authorship.update!(reference: reference)
  end

  def there_is_a_species_described_by_bolton
    reference = create :any_reference, author_string: 'Bolton'
    taxon = create :species
    taxon.protonym.authorship.update!(reference: reference)
  end

  def there_is_a_species_with_locality locality
    protonym = create :protonym, :species_group, locality: locality
    create :species, protonym: protonym
  end

  def there_is_a_species_with_bioregion bioregion
    protonym = create :protonym, :species_group, bioregion: bioregion
    create :species, protonym: protonym
  end

  def there_is_a_species_with_forms forms
    protonym = create :protonym, :species_group, forms: forms
    create :species, protonym: protonym
  end

  def there_is_a_species_with_primary_type_information primary_type_information
    protonym = create :protonym, :species_group, primary_type_information_taxt: primary_type_information
    create :species, protonym: protonym
  end

  def i_should_get_a_download_with_the_filename_and_todays_date filename
    date = Time.current.strftime("%Y-%m-%d")
    content_disposition = page.response_headers['Content-Disposition']
    expect(content_disposition).to include %(filename="#{filename}#{date}__)
  end

  background do
    i_go_to "the advanced search page"
  end

  scenario "Searching when no results" do
    fill_in "year", with: "2010"
    click_button "Search"
    i_should_see "No results"
  end

  scenario "Searching for subfamilies" do
    create :subfamily, name_string: "Formicinae"

    select "Subfamily", from: "type"
    click_button "Search"
    i_should_see "1 result"
  end

  scenario "Searching for valid taxa" do
    create :family, :excluded_from_formicidae

    check "valid_only"
    click_button "Search"
    i_should_see "No results"
  end

  scenario "Searching for an author's descriptions" do
    there_is_a_species_described_by_bolton

    fill_in "author_name", with: "Bolton"
    click_button "Search"
    i_should_see "1 result"
  end

  scenario "Finding a genus" do
    there_is_a_species_in_the_genus "Atta major", "Atta"

    fill_in "genus", with: "Atta"
    click_button "Search"
    i_should_see "Atta major"
  end

  scenario "Searching for locality" do
    there_is_a_species_with_locality "Mexico"
    there_is_a_species_with_locality "Zimbabwe"

    fill_in "locality", with: "Mexico"
    click_button "Search"
    i_should_see "1 result"
    i_should_see "MEXICO", within: 'the search results'
  end

  scenario "Searching for bioregion" do
    there_is_a_species_with_bioregion "Malagasy"
    there_is_a_species_with_bioregion "Afrotropic"
    there_is_a_species_with_bioregion "Afrotropic"

    select "Afrotropic", from: "bioregion"
    click_button "Search"
    i_should_see "2 result(s)"
    i_should_see "Afrotropic", within: 'the search results'
  end

  scenario "Searching for 'None' bioregion" do
    there_is_a_species_with_bioregion "Malagasy"
    there_is_a_species_with_bioregion "Afrotropic"
    there_is_a_species_with_bioregion ""

    select "Species", from: "type"
    select "None", from: "bioregion"
    click_button "Search"
    i_should_see "1 result"
  end

  scenario "Searching in type fields" do
    there_is_a_species_with_primary_type_information "Madagascar: Prov. Toliara"

    fill_in "type_information", with: "Toliara"
    click_button "Search"
    i_should_see "1 result"
  end

  scenario "Searching for a form" do
    there_is_a_species_with_forms "w.q."
    there_is_a_species_with_forms "q."

    fill_in "forms", with: "w."
    click_button "Search"
    i_should_see "1 result"
    i_should_see "w.", within: 'the search results'
  end

  scenario "Searching for 'described in' (range)" do
    there_is_a_species_described_in 2010
    there_is_a_species_described_in 2011
    there_is_a_species_described_in 2012

    fill_in "year", with: "2010-2011"
    click_button "Search"
    i_should_see "2 result"
    i_should_see "2010", within: 'the search results'
    i_should_see "2011", within: 'the search results'
  end

  scenario "Download search results" do
    there_is_a_species_described_in 2010

    fill_in "year", with: "2010"
    click_button "Search"
    i_follow "Download"
    i_should_get_a_download_with_the_filename_and_todays_date "antcat_search_results__"
  end
end

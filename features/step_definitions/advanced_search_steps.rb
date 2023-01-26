# frozen_string_literal: true

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

def there_is_an_invalid_family
  create :family, :excluded_from_formicidae
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

def i_should_get_a_download_with_the_filename_and_todays_date filename
  date = Time.current.strftime("%Y-%m-%d")
  content_disposition = page.response_headers['Content-Disposition']
  expect(content_disposition).to include %(filename="#{filename}#{date}__)
end

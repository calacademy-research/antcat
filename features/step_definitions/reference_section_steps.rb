# frozen_string_literal: true

Given("there is a reference section with the references_taxt {string}") do |references_taxt|
  there_is_a_reference_section_with_the_references_taxt references_taxt
end
def there_is_a_reference_section_with_the_references_taxt references_taxt
  create :reference_section, references_taxt: references_taxt
end

Given("there is a subfamily {string} with a reference section {string}") do |name, references_taxt|
  there_is_a_subfamily_with_a_reference_section name, references_taxt
end
def there_is_a_subfamily_with_a_reference_section name, references_taxt
  taxon = create :subfamily, name_string: name
  create :reference_section, references_taxt: references_taxt, taxon: taxon
end

Given("there is a reference section for {string} that includes a tag for {string}") do |name, tagged_name|
  there_is_a_reference_section_for_that_includes_a_tag_for name, tagged_name
end
def there_is_a_reference_section_for_that_includes_a_tag_for name, tagged_name
  taxon = Taxon.find_by!(name_cache: name)
  tag_taxon = Taxon.find_by!(name_cache: tagged_name)

  create :reference_section, references_taxt: Taxt.tax(tag_taxon.id), taxon: taxon
end

# Editing.
Then("the reference section should be empty") do
  the_reference_section_should_be_empty
end
def the_reference_section_should_be_empty
  expect(page).to_not have_css '#reference-sections .reference_section'
end

Then("the reference section should be {string}") do |content|
  the_reference_section_should_be content
end
def the_reference_section_should_be content
  element = first('#references-section').find('.taxt-presenter')
  expect(element.text).to match(/#{content}/)
end

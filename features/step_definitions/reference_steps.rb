Given("there is a reference") do
  create :article_reference
end

Given("there is an article reference") do
  create :article_reference
end

Given("there is a book reference") do
  create :book_reference
end

Given("this/these reference(s) exist(s)") do |table|
  table.hashes.each do |hash|
    citation = hash.delete('citation') || "Psyche 1:1"
    matches = citation.match /(\w+) (\d+):([\d\-]+)/
    journal = create :journal, name: matches[1]

    hash.merge! journal: journal, series_volume_issue: matches[2], pagination: matches[3]

    create_reference :article_reference, hash
  end
end

Given("these/this book reference(s) exist(s)") do |table|
  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /([^:]+): (\w+), (.*)/

    publisher = create :publisher, name: matches[2], place_name: matches[1]
    hash.merge! publisher: publisher, pagination: matches[3]
    create_reference :book_reference, hash
  end
end

# HACK because I could not get it to work in any other way.
# Special cases because we want specific IDs.
Given("there is a Giovanni reference") do
  reference = create :article_reference,
    citation_year: '1809',
    title: "Giovanni's Favorite Ants"

  reference.update_column :id, 7777
  reference.author_names << create(:author_name, name: 'Giovanni, S.')
end

Given("there is a reference by Giovanni's brother") do
  reference = create :article_reference, title: "Giovanni's Brother's Favorite Ants"

  reference.update_column :id, 7778
  reference.author_names << create(:author_name, name: 'Giovanni, J.')
end

Given("these/this unknown reference(s) exist(s)") do |table|
  table.hashes.each { |hash| create_reference :unknown_reference, hash }
end

def create_reference type, hash
  author = hash.delete 'author'
  author_name = if author
                  AuthorName.find_by(name: author) || create(:author_name, name: author)
                end
  create type, hash.merge(author_names: [author_name])
end

Given("the following entry nests it") do |table|
  data = table.hashes.first
  NestedReference.create! title: data[:title],
    author_names: [create(:author_name, name: data[:author])],
    citation_year: data[:citation_year],
    pages_in: data[:pages_in],
    nesting_reference: Reference.last
end

Given("a Bolton-Fisher reference exists with the title {string}") do |title|
  author_names = [
    AuthorName.find_by(name: "Bolton, B."),
    create(:author_name, name: "Fisher, B.")
  ]
  create :unknown_reference, author_names: author_names, title: title
end

Given("that the entry has a URL that's on our site") do
  reference = Reference.last
  reference.update_attribute :document, ReferenceDocument.create!
  reference.document.update file_file_name: '123.pdf',
    url: "localhost/documents/#{reference.document.id}/123.pdf"
end

When('I fill in "reference_nesting_reference_id" with the ID for {string}') do |title|
  reference = Reference.find_by(title: title)
  step %(I fill in "reference_nesting_reference_id" with "#{reference.id}")
end

Then("I should see a PDF link") do
  find "a", text: "PDF", match: :first
end

When("I fill in {string} with a URL to a document that exists") do |field|
  stub_request :any, "google.com/foo"
  step %(I fill in "#{field}" with "google\.com/foo")
end

Given "there is a reference with ID 50000 for Dolerichoderinae" do
  reference = create :unknown_reference, title: 'Dolerichoderinae'
  reference.update_column :id, 50000
end

def find_reference_by_keey keey
  parts = keey.split ','
  last_name = parts[0]
  year = parts[1]
  Reference.where("author_names_string_cache LIKE ?", "#{last_name}%").find_by(year: year.to_i)
end

Given("the default reference is {string}") do |keey|
  reference = find_reference_by_keey keey
  DefaultReference.stub(:get).and_return reference
end

Given("there is no default reference") do
  DefaultReference.stub(:get).and_return nil
end

When("I fill in the references search box with {string}") do |search_term|
  within('#desktop-menu') do
    step %(I fill in "reference_q" with "#{search_term}")
  end
end

When('I press "Go" by the references search box') do
  find("#header-reference-search-button-test-hook").click
end

When("I hover the export button") do
  find(".btn-normal", text: "Export").hover
end

Then("nesting_reference_id should contain a valid reference id") do
  id = find("#reference_nesting_reference_id").value
  expect(Reference.exists?(id)).to be true
end

Given("there is a taxon with that reference as its protonym's reference") do
  reference = Reference.last
  taxon = create :genus
  taxon.protonym.authorship.reference = reference
  taxon.protonym.authorship.save!
end

Then("the {string} tab should be selected") do |tab_name|
  tab_name = 'Unknown' if tab_name == 'Other'
  find("#tabs-#{tab_name.downcase}.is-active")
end

When("I click the Add to Recently Used button") do
  find("a.add-to-recently-used-references-js-hook").click
end

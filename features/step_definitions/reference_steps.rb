# frozen_string_literal: true

def find_reference_by_keey keey
  parts = keey.split ','
  last_name = parts[0]
  year = parts[1]
  Reference.where("author_names_string_cache LIKE ?", "#{last_name}%").find_by(year: year.to_i)
end

module ReferenceStepsHelpers
  module_function

  def find_or_create_author_names! hsh
    if (author = hsh.delete 'author')
      author_name = AuthorName.find_by(name: author) || FactoryBot.create(:author_name, name: author)
      hsh[:author_names] = [author_name]
    end
  end
end

Given("there is a reference") do
  create :any_reference
end

Given("there is an article reference") do
  create :article_reference
end

Given("there is a book reference") do
  create :book_reference
end

Given("there is an unknown reference") do
  create :unknown_reference
end

Given("(this reference exists)/(these references exist)") do |table|
  table.hashes.each do |hsh|
    ReferenceStepsHelpers.find_or_create_author_names!(hsh)
    create :any_reference, hsh
  end
end

Given("this article reference exists") do |table|
  hsh = table.hashes.first

  citation = hsh.delete('citation') || "Psyche 1:1"
  matches = citation.match(/(\w+) (\d+):([\d\-]+)/)
  journal = Journal.find_by(name: matches[1]) || create(:journal, name: matches[1])

  hsh.merge!(journal: journal, series_volume_issue: matches[2], pagination: matches[3])

  ReferenceStepsHelpers.find_or_create_author_names!(hsh)

  create :article_reference, hsh
end

Given("the following entry nests it") do |table|
  hsh = table.hashes.first

  NestedReference.create!(
    title: hsh[:title],
    author_names: [create(:author_name, name: hsh[:author])],
    citation_year: hsh[:citation_year],
    pagination: hsh[:pagination],
    nesting_reference: Reference.last
  )
end

When('I fill in "reference_nesting_reference_id" with the ID for {string}') do |title|
  reference = Reference.find_by!(title: title)
  step %(I fill in "reference_nesting_reference_id" with "#{reference.id}")
end

Then("I should see a PDF link") do
  find "a", text: "PDF", match: :first
end

When("I fill in {string} with a URL to a document that exists") do |field_name|
  stub_request :any, "http://google.com/foo"
  step %(I fill in "#{field_name}" with "http://google\.com/foo")
end

Given("the default reference is {string}") do |keey|
  reference = find_reference_by_keey keey
  References::DefaultReference.stub(:get).and_return(reference)
end

Then("nesting_reference_id should contain a valid reference id") do
  id = find("#reference_nesting_reference_id").value
  expect(Reference.exists?(id)).to be true
end

Given("there is a reference referenced in a history item") do
  reference = create :any_reference
  create :taxon_history_item, taxt: "{ref #{reference.id}}"
end

Then("the {string} tab should be selected") do |tab_name|
  tab_name = 'Unknown' if tab_name == 'Other'
  find("#tabs-#{tab_name.downcase}.is-active")
end

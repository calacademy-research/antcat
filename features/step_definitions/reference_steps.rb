# frozen_string_literal: true

Given("there is a reference") do
  create :any_reference, :with_author_name
end

Given("there is an article reference") do
  create :article_reference, :with_author_name
end

Given("there is a book reference") do
  create :book_reference, :with_author_name
end

Given("(this reference exists)/(these references exist)") do |table|
  table.hashes.each do |hsh|
    if (author_name_name = hsh.delete('author'))
      author_name = ReferenceStepsHelpers.find_or_create_author_name(author_name_name)
      hsh[:author_names] = [author_name]
    end

    create :any_reference, hsh
  end
end

Given("this article reference exists") do |table|
  hsh = table.hashes.first

  if (author_name_name = hsh.delete('author'))
    author_name = ReferenceStepsHelpers.find_or_create_author_name(author_name_name)
    hsh[:author_names] = [author_name]
  end

  if (journal_name = hsh.delete('journal'))
    journal = Journal.find_by(name: journal_name) || create(:journal, name: journal_name)
    hsh[:journal] = journal
  end

  create :article_reference, hsh
end

Given("the following entry nests it") do |table|
  hsh = table.hashes.first

  create :nested_reference,
    title: hsh[:title],
    author_names: [create(:author_name, name: hsh[:author])],
    year: hsh[:year],
    year_suffix: hsh[:year_suffix],
    pagination: hsh[:pagination],
    nesting_reference: Reference.last
end

When("I select the reference tab {string}") do |tab_css_selector|
  find(tab_css_selector, visible: false).click
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

Given("the default reference is {string}") do |key_with_year|
  reference = ReferenceStepsHelpers.find_reference_by_key(key_with_year)
  References::DefaultReference.stub(:get).and_return(reference)
end

Then("nesting_reference_id should contain a valid reference id") do
  id = find("#reference_nesting_reference_id").value
  expect(Reference.exists?(id)).to eq true
end

Given("there is a reference referenced in a history item") do
  reference = create :any_reference
  create :taxon_history_item, taxt: "{ref #{reference.id}}"
end

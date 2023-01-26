# frozen_string_literal: true

Given("there is a reference") do
  there_is_a_reference
end
def there_is_a_reference
  create :any_reference, :with_author_name
end

Given("there is an article reference") do
  there_is_an_article_reference
end
def there_is_an_article_reference
  create :article_reference, :with_author_name
end

Given("there is a book reference") do
  there_is_a_book_reference
end
def there_is_a_book_reference
  create :book_reference, :with_author_name
end

Given(/^(?:this reference exists|these references exist)$/) do |table|
  table.hashes.each do |hsh|
    if (author_name_name = hsh.delete('author'))
      author_name = ReferenceStepsHelpers.find_or_create_author_name(author_name_name)
      hsh[:author_names] = [author_name]
    end

    create :any_reference, hsh
  end
end
def this_reference_exists **hsh
  if (author_name_name = hsh.delete(:author))
    author_name = ReferenceStepsHelpers.find_or_create_author_name(author_name_name)
    hsh[:author_names] = [author_name]
  end

  create :any_reference, hsh
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
def this_article_reference_exists **hsh
  if (author_name_name = hsh.delete(:author))
    author_name = ReferenceStepsHelpers.find_or_create_author_name(author_name_name)
    hsh[:author_names] = [author_name]
  end

  if (journal_name = hsh.delete(:journal))
    journal = Journal.find_by(name: journal_name) || create(:journal, name: journal_name)
    hsh[:journal] = journal
  end

  create :article_reference, hsh
end

Given("the following entry nests it") do |table|
  hsh = table.hashes.first

  create :nested_reference,
    title: hsh[:title],
    author_string: hsh[:author],
    year: hsh[:year],
    year_suffix: hsh[:year_suffix],
    pagination: hsh[:pagination],
    nesting_reference: Reference.last
end
# Inlined.

When("I select the reference tab {string}") do |tab_css_selector|
  i_select_the_reference_tab tab_css_selector
end
def i_select_the_reference_tab tab_css_selector
  find(tab_css_selector, visible: false).click
end

When('I fill in "reference_nesting_reference_id" with the ID for {string}') do |title|
  i_fill_in_reference_nesting_reference_id_with_the_id_for title
end
def i_fill_in_reference_nesting_reference_id_with_the_id_for title
  reference = Reference.find_by!(title: title)
  i_fill_in "reference_nesting_reference_id", with: reference.id
end

Given("the default reference is {string}") do |key_with_year|
  the_default_reference_is key_with_year
end
def the_default_reference_is key_with_year
  reference = ReferenceStepsHelpers.find_reference_by_key(key_with_year)
  References::DefaultReference.stub(:get).and_return(reference)
end

Then("nesting_reference_id should contain a valid reference id") do
  nesting_reference_id_should_contain_a_valid_reference_id
end
def nesting_reference_id_should_contain_a_valid_reference_id
  id = find("#reference_nesting_reference_id").value
  expect(Reference.exists?(id)).to eq true
end

Given("there is a reference referenced in a history item") do
  there_is_a_reference_referenced_in_a_history_item
end
def there_is_a_reference_referenced_in_a_history_item
  reference = create :any_reference
  create :history_item, :taxt, taxt: Taxt.ref(reference.id)
end

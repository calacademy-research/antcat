# frozen_string_literal: true

Given("there is a wiki page {string}") do |title|
  there_is_a_wiki_page title
end
def there_is_a_wiki_page title
  create :wiki_page, title: title
end

# frozen_string_literal: true

def there_is_a_wiki_page title
  create :wiki_page, title: title
end

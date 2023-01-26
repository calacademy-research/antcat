# frozen_string_literal: true

Given("there is an open issue {string}") do |title|
  there_is_an_open_issue title
end
def there_is_an_open_issue title
  create :issue, :open, title: title, user: User.first
end

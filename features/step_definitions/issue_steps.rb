# frozen_string_literal: true

def there_is_an_open_issue title
  create :issue, :open, title: title, user: User.first
end

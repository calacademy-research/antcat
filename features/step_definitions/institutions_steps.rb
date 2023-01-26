# frozen_string_literal: true

Given(/^there is an institution "([^"]*)" \("([^"]*)"\)$/) do |abbreviation, name|
  there_is_an_institution abbreviation, name
end
def there_is_an_institution abbreviation, name
  create :institution, abbreviation: abbreviation, name: name
end

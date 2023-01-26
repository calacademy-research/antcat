# frozen_string_literal: true

def there_is_an_institution abbreviation, name
  create :institution, abbreviation: abbreviation, name: name
end

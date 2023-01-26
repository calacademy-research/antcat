# frozen_string_literal: true

def there_is_a_subfamily name
  create :subfamily, name_string: name
end

def there_is_an_invalid_subfamily_ivalidinae
  create :subfamily, :unidentifiable, name_string: "Invalidinae"
end

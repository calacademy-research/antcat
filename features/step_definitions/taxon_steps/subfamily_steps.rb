# frozen_string_literal: true

Given("there is a subfamily {string}") do |name|
  there_is_a_subfamily name
end
def there_is_a_subfamily name
  create :subfamily, name_string: name
end

Given("there is an invalid subfamily Invalidinae") do
  there_is_an_invalid_subfamily_ivalidinae
end
def there_is_an_invalid_subfamily_ivalidinae
  create :subfamily, :unidentifiable, name_string: "Invalidinae"
end

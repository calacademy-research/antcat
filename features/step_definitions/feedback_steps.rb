# frozen_string_literal: true

Given("there is an open feedback item") do
  there_is_an_open_feedback_item
end
def there_is_an_open_feedback_item
  create :feedback, user: nil
end

Given("there is a closed feedback item") do
  there_is_a_closed_feedback_item
end
def there_is_a_closed_feedback_item
  create :feedback, :closed
end

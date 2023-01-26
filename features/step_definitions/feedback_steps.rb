# frozen_string_literal: true

def there_is_an_open_feedback_item
  create :feedback, user: nil
end

def there_is_a_closed_feedback_item
  create :feedback, :closed
end

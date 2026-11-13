# frozen_string_literal: true

# A reference to a book, with its publisher.
class BookReference < Reference
  belongs_to :publisher
end

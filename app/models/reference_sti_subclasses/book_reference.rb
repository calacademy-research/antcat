# frozen_string_literal: true

class BookReference < Reference
  belongs_to :publisher

  validates :pagination, presence: true
end

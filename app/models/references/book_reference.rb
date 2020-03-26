# frozen_string_literal: true

class BookReference < Reference
  belongs_to :publisher

  validates :year, :publisher, :pagination, presence: true
end

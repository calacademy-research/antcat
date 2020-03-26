# frozen_string_literal: true

class UnknownReference < Reference
  validates :year, :citation, presence: true
end

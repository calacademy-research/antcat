# frozen_string_literal: true

class UnknownReference < Reference
  validates :citation, presence: true
end

# frozen_string_literal: true

class Locality
  def self.unique_sorted
    Protonym.distinct.pluck(:locality).compact.sort
  end
end

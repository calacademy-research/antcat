class Locality < ApplicationRecord
  def self.unique_sorted
    Protonym.distinct.pluck(:locality).compact.sort
  end
end

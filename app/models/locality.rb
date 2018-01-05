class Locality < ActiveRecord::Base
  def self.unique_sorted
    Protonym.distinct.pluck(:locality).compact.sort
  end
end

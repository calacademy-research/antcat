class Locality < ActiveRecord::Base
  def self.unique_sorted
    Protonym.uniq.pluck(:locality).compact.sort
  end
end

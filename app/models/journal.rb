class Journal < ActiveRecord::Base
  has_many :issues

  def self.import data
    find_or_create_by_title(data[:title])
  end
end

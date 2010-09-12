class Publisher < ActiveRecord::Base
  has_many :books

  def self.import data
    find_or_create_by_name_and_place(data[:name], data[:place])
  end

end

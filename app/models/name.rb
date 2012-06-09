class Name < ActiveRecord::Base

  validates :name, presence: true

  def self.import name
    find_or_create_by_name name: name
  end

end

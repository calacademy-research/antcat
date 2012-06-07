class Name < ActiveRecord::Base

  validates :name, presence: true

  def self.import name
    create! name: name
  end

end

class Name < ActiveRecord::Base

  validates :name, presence: true

  def full_name
    name
  end

  def self.import name, data = {}
    case
    when data[:genus_name] then GenusName
    when data[:subgenus_name] then SubgenusName
    else Name
    end.new.import name, data
  end

  def import name, data
    name_object = self.class.find_by_name name
    return name_object if name_object
    self.name = name
    save!
    self
  end

end

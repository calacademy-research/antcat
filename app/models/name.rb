class Name < ActiveRecord::Base

  validates :name, presence: true

  def full_name
    name
  end

  def self.import name, data = {}
    SpeciesName.import(name, data)  or
    SubgenusName.import(name, data) or
    GenusName.import(name, data)    or
    SubtribeName.import(name, data) or
    TribeName.import(name, data)    or
    FamilyOrSubfamilyName.import(name, data)
  end

  def import name, data
    name_object = self.class.find_by_name name
    return name_object if name_object
    self.name = name
    save!
    self
  end

end

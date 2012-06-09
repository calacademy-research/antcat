class Name < ActiveRecord::Base

  validates :name, presence: true

  def self.import data
    SpeciesName.import(data)  or
    SubgenusName.import(data) or
    GenusName.import(data)    or
    SubtribeName.import(data) or
    TribeName.import(data)    or
    SubfamilyName.import(data)or
    FamilyName.import(data)   or
    FamilyOrSubfamilyName.import(data) or
    raise "No Name subclass wanted #{data}"
  end

end

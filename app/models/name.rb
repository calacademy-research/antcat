class Name < ActiveRecord::Base

  validates :name, presence: true

  def self.import name, data = {}
    SpeciesName.import(name, data)  or
    SubgenusName.import(name, data) or
    GenusName.import(name, data)    or
    SubtribeName.import(name, data) or
    TribeName.import(name, data)    or
    FamilyOrSubfamilyName.import(name, data)
  end

end

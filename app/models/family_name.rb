class FamilyName < FamilyOrSubfamilyName

  def self.import data
    return unless name = data[:family_name]
    create! name: name
  end

  def rank
    'family'
  end

end

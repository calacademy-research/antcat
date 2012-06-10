class FamilyOrSubfamilyName < Name

  def self.import data
    return unless name = data[:family_or_subfamily_name]
    create! name: name
  end

  def rank
    'family_or_subfamily'
  end

end

class FamilyOrSubfamilyName < Name

  def self.get_name data
    data[:family_or_subfamily_name]
  end

  def rank
    'family_or_subfamily'
  end

end

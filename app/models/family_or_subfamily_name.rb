class FamilyOrSubfamilyName < Name

  def self.import name, data = {}
    return unless name = data[:family_or_subfamily_name]
    create! name: name
  end

end

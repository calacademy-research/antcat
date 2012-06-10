class FamilyName < FamilyOrSubfamilyName

  def import data
    return unless name = data[:family_name]
    create! name: name
  end

end

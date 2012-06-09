class SubfamilyName < FamilyOrSubfamilyName

  def self.import data
    return unless name = data[:subfamily_name]
    create! name: name
  end

end

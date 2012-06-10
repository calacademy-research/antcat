class SubfamilyName < FamilyOrSubfamilyName

  def self.import data
    return unless name = data[:subfamily_name]
    Name.find_by_name(name) || create!(name: name)
  end

  def rank
    'subfamily'
  end

end

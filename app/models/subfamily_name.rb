class SubfamilyName < FamilyOrSubfamilyName

  def self.get_name data
    data[:subfamily_name]
  end

  def rank
    'subfamily'
  end

end

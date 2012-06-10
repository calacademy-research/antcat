class SubgenusName < GenusGroupName

  def self.import data
    return unless name = data[:subgenus_name]
    Name.find_by_name(name) || create!(name: name)
  end

  def rank
    'subgenus'
  end

end

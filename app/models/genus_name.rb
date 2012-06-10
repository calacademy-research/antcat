class GenusName < GenusGroupName

  def self.import data
    return unless name = data[:genus_name]
    Name.find_by_name(name) || create!(name: name)
  end

  def rank
    'genus'
  end

end

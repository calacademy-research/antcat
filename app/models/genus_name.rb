class GenusName < GenusGroupName

  def self.import data
    return unless name = data[:genus_name]
    create! name: name
  end

end

class GenusName < GenusGroupName

  def self.import name, data = {}
    return unless name = data[:genus_name]
    create! name: name
  end

end

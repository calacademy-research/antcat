class SubgenusName < GenusGroupName

  def self.import name, data = {}
    return unless name = data[:subgenus_name]
    create! name: name
  end

end

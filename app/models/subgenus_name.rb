class SubgenusName < GenusGroupName

  def self.import data
    return unless name = data[:subgenus_name]
    create! name: name
  end

end

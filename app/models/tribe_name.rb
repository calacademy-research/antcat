class TribeName < Name

  def self.import data
    return unless name = data[:tribe_name]
    create! name: name
  end

end

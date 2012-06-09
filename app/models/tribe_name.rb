class TribeName < Name

  def self.import name, data = {}
    return unless name = data[:tribe_name]
    create! name: name
  end

end

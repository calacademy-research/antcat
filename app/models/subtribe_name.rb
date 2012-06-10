class SubtribeName < Name

  def self.import data
    return unless name = data[:subtribe_name]
    Name.find_by_name(name) || create!(name: name)
  end

end

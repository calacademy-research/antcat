class SubtribeName < Name

  def self.import data
    return unless name = data[:subtribe_name]
    create! name: name
  end

end

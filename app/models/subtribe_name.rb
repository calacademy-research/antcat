class SubtribeName < Name

  def self.get_name data
    data[:subtribe_name]
  end

  def rank
    'subtribe'
  end

end

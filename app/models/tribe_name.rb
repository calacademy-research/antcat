class TribeName < Name

  def self.get_name data
    data[:tribe_name]
  end

  def rank
    'tribe'
  end

end

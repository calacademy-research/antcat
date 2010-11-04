module PublisherParser

  def self.parse string
    return unless matches = string.match(/(?:(.*?): ?)(.*)/)
    {:name => matches[2], :place => matches[1]}
  end

end

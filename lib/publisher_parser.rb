module PublisherParser

  def self.get_parts string
    return {} unless string.present?
    matches = string.match /(?:(.*?): ?)?(.*)/
    {:name => matches[2], :place => matches[1]}
  end

end

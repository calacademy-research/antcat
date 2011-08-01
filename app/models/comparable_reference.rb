class ComparableReference
  include ReferenceComparable
  attr_accessor :author, :year, :title, :type, :series_volume_issue, :pagination

  def initialize hash = {}
    update hash
  end

  def update hash
    hash.each do |key, value|
      send "#{key}=", value
    end
  end

  def id
    object_id
  end

  def to_s
    "#{type}: #{author}, #{year}. #{title}. #{series_volume_issue}. #{pagination}"
  end

end

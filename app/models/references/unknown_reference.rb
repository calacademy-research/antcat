class UnknownReference < Reference
  validates_presence_of :year, :citation
  attr_accessible :year
end

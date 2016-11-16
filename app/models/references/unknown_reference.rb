class UnknownReference < Reference
  attr_accessible :year

  validates_presence_of :year, :citation
end

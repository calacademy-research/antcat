class BookReference < Reference
  attr_accessible :year, :publisher, :doi

  belongs_to :publisher

  validates_presence_of :year, :publisher, :pagination
end

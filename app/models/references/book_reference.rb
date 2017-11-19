class BookReference < Reference
  belongs_to :publisher

  validates_presence_of :year, :publisher, :pagination
end

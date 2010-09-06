class BookReference < Reference
  belongs_to :book, :foreign_key => :source_id

  def self.import data
    create! :book => Book.import(data)
  end

  def import data

  end
end

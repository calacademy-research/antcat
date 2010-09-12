class BookReference < Reference
  belongs_to :publisher

  def self.import create_data, data
    BookReference.create! create_data.merge(
      :pagination => data[:pagination],
      :publisher => Publisher.import(data[:publisher])
    )
  end
end

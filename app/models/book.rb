class Book < Source
  def self.import data
    Book.find_or_create_by_authors_and_year_and_title(
      :authors => data[:authors],
      :year => data[:year],
      :title => data[:title],
      :place => data[:book][:publisher][:place],
      :publisher => data[:book][:publisher][:name],
      :pagination => data[:book][:pagination])
  end
end

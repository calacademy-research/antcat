class Book < Source
  def self.import data
    Book.create!(
      :authors => Author.import(data[:authors]),
      :year => data[:year],
      :title => data[:title],
      :place => data[:book][:publisher][:place],
      :publisher => data[:book][:publisher][:name],
      :pagination => data[:book][:pagination])
  end
end

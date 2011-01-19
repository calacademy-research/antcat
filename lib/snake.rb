class Array
  def snake column_count
    snake = []
    row_count = (size.to_f / column_count).ceil
    row_count.times do |row_index|
      snake[row_index] = []
      column_count.times do |column_index|
        snake[row_index][column_index] = self[row_index + column_index * row_count]
      end
    end
    snake
  end
end

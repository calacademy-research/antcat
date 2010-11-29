class DiazBetancourt < ActiveRecord::Migration
  def self.up
    author_name = AuthorName.find_by_name "Diaz Betancourt, M. E."
    author_name.name = "Díaz Betancourt, M. E."
    author_name.save!
  end

  def self.down
  end
end

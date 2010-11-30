class Guenard < ActiveRecord::Migration
  def self.up
    author_name = AuthorName.find_by_name "Guenard, B."
    author_name.name = "Guénard, B."
    author_name.save!
  end

  def self.down
  end
end

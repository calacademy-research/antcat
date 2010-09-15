class AuthorsActsAsList < ActiveRecord::Migration
  def self.up
    add_column :author_participations, :position, :integer
  end

  def self.down
  end
end

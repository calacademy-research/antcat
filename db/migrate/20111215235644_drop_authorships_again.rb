class DropAuthorshipsAgain < ActiveRecord::Migration
  def self.up
    drop_table :authorships
  end

  def self.down
  end
end

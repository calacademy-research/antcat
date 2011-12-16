class DropAuthorshipsAgain < ActiveRecord::Migration
  def self.up
    drop_table :authorships rescue nil
  end

  def self.down
  end
end

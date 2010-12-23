class AddOriginalToBoltonReference < ActiveRecord::Migration
  def self.up
    add_column :bolton_references, :original, :text
  end

  def self.down
    remove_column :bolton_references, :original
  end
end

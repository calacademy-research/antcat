class AddPlaceToBoltonReference < ActiveRecord::Migration
  def self.up
    add_column :bolton_references, :place, :string
  end

  def self.down
    remove_column :bolton_references, :place
  end
end
